//
//  CalendarViewController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 03/12/11.
//  Copyright (c) 2012 Salesforce.com. All rights reserved.
//

#import "AllEventsViewController.h"
#import "Utils.h"
#import "Day.h"
#import "SFDC.h"
#import "ZKUserInfo.h"
#import "ATEvent.h"


@implementation AllEventsViewController

//@synthesize ipadevents;
@synthesize week;
@synthesize dayheaders;
@synthesize startdate;
@synthesize enddate;
@synthesize tableview;
@synthesize selectedipadevent;
@synthesize selectedevent;
//@synthesize salesforceeventkeys;
//@synthesize salesforceevents;
@synthesize allevents;

- (void)dealloc
{
    [week release];
    [dayheaders release];
    [startdate release];
    [enddate release];
//    [ipadevents release];
    [tableview release];
//    [salesforceeventkeys release];
//    [salesforceevents release];
    [allevents release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        store = [[EKEventStore alloc] init];
//        salesforceeventkeys = [[NSMutableSet alloc] init];
//        salesforceevents = [[NSMutableDictionary alloc] init];
        allevents = [[NSMutableDictionary alloc] init];
        week = [[NSMutableDictionary alloc] init];
        dayheaders = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self queryForEvents];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


//query iCal and SFDC events
-(void)queryForEvents {

    [[self allevents] removeAllObjects];
    [week removeAllObjects];
    [dayheaders removeAllObjects];
    
    
    //check if the users wants to include ipad events as well in the list
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *needtoshowipadevents = [defaults objectForKey:@"ATShowIPadEvents"];

    if(needtoshowipadevents == nil || [needtoshowipadevents isEqualToString:@"YES"]) {
        // Create the predicate.
        NSPredicate *predicate = [store predicateForEventsWithStartDate:[self startdate] endDate:[self enddate] calendars:nil];
        
        // Fetch all events that match the predicate.
        NSArray *ipadevents = [store eventsMatchingPredicate:predicate];
        
        //drop them in the allevents dictionary with fake key and value
        for(EKEvent *ev in ipadevents) {
            //calculate the startdatetime_title string
            NSString *trimmedtitle = [[ev title] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *localkey = [[NSString alloc] initWithFormat:@"%@_%@", [Utils formatDateTimeAsStringUTC:[ev startDate]], trimmedtitle];
            ATEvent *atevent = [[ATEvent alloc] init];
            [atevent withEKEvent:ev];
            [allevents setObject:atevent forKey:localkey];
            [atevent release];
        }
    }
    
    
    
    
    //also fetch the events from Salesforce
    //query salesforce for Events in the same interval
    ZKSforceClient *client = [[SFDC sharedInstance] client];
    ZKUserInfo *uinfo =  [client currentUserInfo];
    
    NSString *userid = [uinfo userId];
    NSString *activitiesquery = [[NSString alloc ] initWithFormat:@"select Id, Subject, ActivityDateTime, EndDateTime, Location, What.Name, WhatId, StartDateTime, DurationInMinutes, Description, Type from Event where OwnerId ='%@' and ActivityDate >=%@ and ActivityDate <=%@ order by StartDateTime limit 200", userid, [Utils formatDateAsString:[self startdate]], [Utils formatDateAsString:[self enddate]]];
    
    @try {
        ZKQueryResult *result = [client query:activitiesquery];
        //drop them in the allevents eventkeys set
         for(ZKSObject *sfdcEvent in [result records]) {
             //all day events have an empty ActivityDateTime ... need to fix that. Skip for now
             if([sfdcEvent fieldValue:@"ActivityDateTime"] == nil) continue;
             
             //let's create a fake key to compare : startdatetimeinutc_subject
             NSString *eventkey = [[[NSString alloc ] initWithFormat:@"%@_%@", [sfdcEvent fieldValue:@"ActivityDateTime"], [sfdcEvent fieldValue:@"Subject"]] autorelease];
             //drop those events in the dictionary
             ATEvent *atevent = [[ATEvent alloc] init];
             [atevent withSFDCEvent:sfdcEvent];
             
             //do a check if an iPad event is already in the dictionary. If so, put the eventidentifier in the ATEvent. That will allow us to double-delete SFDC and iPad events if the users wishes so
             if([allevents objectForKey:eventkey]) {
                 //get the iPad event
                 ATEvent *temp = [allevents objectForKey:eventkey];
                 [atevent setEkeventid:[temp ekeventid]];
             }
             //this setObject will replace any existing atevent when the key is the same
             [allevents setObject:atevent forKey:eventkey];
             [atevent release];
         }
         [self.tableview reloadData];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: [exception description]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [activitiesquery release];

    
    
    //get all the ATEvents from the dictionary and sort 'm
    NSArray *sortedevents;
    
    sortedevents = [[allevents allValues] sortedArrayUsingComparator:^(id a, id b) {
        NSDate *first = [(ATEvent*)a startdate];
        NSDate *second = [(ATEvent*)b startdate];
        return [first compare:second];
    }];
    

    
    //move the activities over to our week array, creating day objects holding the activities
    for(ATEvent *evt in sortedevents) {
        NSString *dayheader = [Utils dayDescriptionFromDate:[evt startdate]];
        
        //add the dayheader for the UITableView Sections
        if(![dayheaders containsObject:dayheader]) [dayheaders addObject:dayheader];
        
        //if there's no day in the week array yet, create one, add a day and set the first activity in that day
        if([week count] == 0) {
            Day *d = [[Day alloc] init];
            d.description = dayheader;
            [d addEvent:evt];
            [week setObject:d forKey:dayheader];
            [d release];
            continue;
        }
        //if the last activity of the last day in the week array is already there, add this activity to that day
        if([week objectForKey:dayheader]) {
            [[week objectForKey:dayheader] addEvent:evt];
        }
        //if it isn't, create a new Day and add the event to that
        else {
            Day *d = [[Day alloc] init];
            d.description = dayheader;
            [d addEvent:evt];
            [week setObject:d forKey:dayheader];
            [d release];
        }
    }

    [[self tableview] reloadData];
    
}


/*
 TABLE SECTION COUNT
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(!allevents) return 0;
    return [[self dayheaders] count];
}



/*
 TABLE SECTION HEADERS
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [dayheaders objectAtIndex:section];
}





/*
 TABLE ROWS COUNT
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!allevents) return 0;
    //find the dayheader name for the section
    NSString *dayheader = [dayheaders objectAtIndex:section];
    
    //get the number of events for that day
    //[[[week objectForKey:dayheader] events] count];
    
    // Return the number of rows in the section.
    return [[[week objectForKey:dayheader] events] count];
}





/*
 TABLE CELL RENDERING
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellEvents";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(!week) return cell;
    
    // Configure the cell...
    NSString *dayheader = [dayheaders objectAtIndex:[indexPath section]];
    Day *d = [week objectForKey:dayheader];
    //cell.textLabel.text = [[self.dataRows objectAtIndex:[indexPath row]] fieldValue:@"Subject"];
    //NSLog(@"DEBUG : %@ - %@", indexPath, dayheader);
    
    
    //TODO : Handle all day events ... right now they're skipped in the query
    
    ATEvent *ev = [d.events objectAtIndex:[indexPath row]];
    cell.textLabel.text = [ev subject];
    
    //detail text will be the start and end time of the activity
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"HH:mm"];
    NSDate *starttime = [ev startdate];
    NSDate *endtime = [ev enddate];
    
    NSString *activitytime = [[NSString alloc] initWithFormat:@"%@ - %@", [dtf stringFromDate:starttime],[dtf stringFromDate:endtime]];
    cell.detailTextLabel.text = activitytime;
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    
    //detect which events are already in salesforce
    if([ev isSFDCEvent]) {
        UIImage *alreadysyncedimage = [UIImage imageNamed:@"datePicker16.gif"];
        UIImage *okimage = [UIImage imageNamed:@"datePicker16ok.gif"];
        UIImage *halfokimage = [UIImage imageNamed:@"datePicker16halfok.gif"];

        cell.imageView.image = alreadysyncedimage;
        if([[ev whatid] length] == 0 && [[ev type] length] == 0) {
            cell.imageView.image = alreadysyncedimage;
        }
        if([[ev whatid] length] != 0 || [[ev type] length] != 0 ) {
            cell.imageView.image = halfokimage;
        }
        if([[ev whatid] length] != 0 && [[ev type] length] != 0 ) {
            cell.imageView.image = okimage;
        }
    }
    else {
        UIImage *calimage = [UIImage imageNamed:@"Calendar16.png"];
        cell.imageView.image = calimage;
    }
    
    
    [activitytime release];
    [dtf release];
    return cell;
}



/*
 SELECT PREVIOUS OR NEXT WEEK
 */
- (IBAction)changeWeek:(id)sender {
    UISegmentedControl *segc = sender;
    switch (segc.selectedSegmentIndex) {
		case 0:
            self.startdate = [Utils substractOneWeek:self.startdate];
            self.enddate = [Utils substractOneWeek:self.enddate];
            [self queryForEvents];
			break;
		case 1:
            self.startdate = [Utils startOfWeek];
            self.enddate = [Utils endOfWeek];
            [self queryForEvents];
			break;
        case 2:
			self.startdate = [Utils addOneWeek:self.startdate];
            self.enddate = [Utils addOneWeek:self.enddate];
            [self queryForEvents];
            break;
            
		default:
            break;
    }
}

/*
 HANDLE TABLE CELL SELECTS
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"selected row : %d", [indexPath row]);
    //week holds Day objects, Days hold event objects
    NSString *dayheader = [dayheaders objectAtIndex:[indexPath section]];
    Day *d = [week objectForKey:dayheader];
    //EKEvent *event = [d.events objectAtIndex:[indexPath row]];
    ATEvent *event = [d.events objectAtIndex:[indexPath row]];
    selectedevent = event;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EVENTSELECTED" object:self];
}


//A notification will be dispatched from the detail view to the app delegate, calling this method when an ipad event is saved to salesforce
//ipad event saved to salesforce
-(void)eventsaved:(NSNotification *)notification {
    CGPoint yoffset = tableview.contentOffset;
    [self queryForEvents];
    [[self tableview] reloadData];
    tableview.contentOffset = yoffset;
}


/*
 if the user preferences about showing the ipad items changes, reload
 */
-(void)showsettingschanged:(NSNotification*)notification {
    [self queryForEvents];
}

@end
