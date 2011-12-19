//
//  CalendarViewController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 03/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarViewController.h"
#import "Utils.h"
#import "Day.h"
#import "FDCServerSwitchboard.h"
#import "ZKUserInfo.h"

@implementation CalendarViewController

@synthesize dataRows;
@synthesize week;
@synthesize dayheaders;
@synthesize startdate;
@synthesize enddate;
@synthesize tableview;
@synthesize selectedipadevent;
@synthesize salesforceevents;

- (void)dealloc
{
    [week release];
    [dayheaders release];
    [startdate release];
    [enddate release];
    [dataRows release];
    [tableview release];
    [selectedipadevent release];
    [salesforceevents release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        store = [[EKEventStore alloc] init];
        salesforceevents = [[NSMutableSet alloc] init];
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
    self.startdate = [Utils startOfWeek];
    self.enddate = [Utils endOfWeek];
    
    [self queryiPadCalendar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //store = nil;
    //salesforceevents = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


//query iCal events
-(void)queryiPadCalendar {
    //NSDate *startDate = [Utils startOfWeek];
    //NSDate *endDate = [Utils endOfWeek];
    // Create the predicate.
    NSPredicate *predicate = [store predicateForEventsWithStartDate:[self startdate] endDate:[self enddate] calendars:nil];
    
    // Fetch all events that match the predicate.
    self.dataRows = [NSMutableArray arrayWithArray:[store eventsMatchingPredicate:predicate]];
    
    
    //this query runs everytime the week is switched. Make sure that we release
    if(week != nil) {
        [week release];
    }
    if(dayheaders != nil) {
        [dayheaders release];
    }
    
    
    //move the activities over to our week array, creating day objects holding the activities
    week = [[NSMutableDictionary alloc] init];
    dayheaders = [[NSMutableArray alloc] init];
    for(EKEvent *ev in [self dataRows]) {
        NSString *dayheader = [Utils dayDescriptionFromDate:[ev startDate]];
        //add the dayheader for the UITableView Sections
        if(![dayheaders containsObject:dayheader]) [dayheaders addObject:dayheader];
        
        //if there's no day in the week array yet, create one, add a day and set the first activity in that day
        if([week count] == 0) {
            Day *d = [[Day alloc] init];
            d.description = dayheader;
            [d addEvent:ev];
            [week setObject:d forKey:dayheader];
            [d release];
            continue;
        }
        //if the last activity of the last day in the week array is already there, add this activity to that day
        //Day *compareday = [week objectForKey:dayheader];
        if([week objectForKey:dayheader]) {
            [[week objectForKey:dayheader] addEvent:ev];
        }
        //if it isn't, create a new Day and add the event to that
        else {
            Day *d = [[Day alloc] init];
            d.description = dayheader;
            [d addEvent:ev];
            [week setObject:d forKey:dayheader];
            [d release];
        }
    }
    
    //also fetch the events from Salesforce
    //query salesforce for Events in the same interval
    ZKUserInfo *uinfo = [[FDCServerSwitchboard switchboard] userInfo];
    
    NSString *userid = [uinfo userId];
    NSString *activitiesquery = [[NSString alloc ] initWithFormat:@"select Id, Subject, ActivityDateTime from Event where OwnerId ='%@' and ActivityDate >=%@ and ActivityDate <=%@ order by StartDateTime limit 200", userid, [Utils formatDateAsString:[self startdate]], [Utils formatDateAsString:[self enddate]]];

    //NSLog(@"Querying for : %@", activitiesquery);
    [[self salesforceevents]removeAllObjects];
    
    [[FDCServerSwitchboard switchboard] query:activitiesquery target:self selector:@selector(queryResult:error:context:) context:nil];
    
    //[self.tableview reloadData];
    [activitiesquery release];
}


- (void)queryResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    //NSLog(@"Error description %@", [error description]);
    
    //drop them in the salesforce events set. We'll use this to compare against the iPad calendar events
    for(ZKSObject *sfdcEvent in [result records]) {
        //let's create a fake key to compare : startdatetimeinutc_subject
        NSString *eventkey = [[NSString alloc ] initWithFormat:@"%@_%@", [sfdcEvent fieldValue:@"ActivityDateTime"], [sfdcEvent fieldValue:@"Subject"]];
        //NSLog(@"Added eventkey : %@", eventkey);
        [[self salesforceevents] addObject:eventkey];
        [eventkey release];
    }
    [self.tableview reloadData];
}


/*
 TABLE SECTION COUNT
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(!dataRows) return 1;
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
    if(!dataRows) return 1;
    //find the dayheader name for the section
    NSString *dayheader = [dayheaders objectAtIndex:section];
    
    //get the number of events for that day
    //[[[week objectForKey:dayheader] events] count];
    
    // Return the number of rows in the section.
    return [[[week objectForKey:dayheader] events] count];;
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
    EKEvent *ev = [d.events objectAtIndex:[indexPath row]];
    cell.textLabel.text = [ev title];
    
    //detail text will be the start and end time of the activity
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"HH:mm"];
    NSDate *starttime = [ev startDate];
    NSDate *endtime = [ev endDate];
    NSString *activitytime = [[NSString alloc] initWithFormat:@"%@ - %@", [dtf stringFromDate:starttime],[dtf stringFromDate:endtime]];
    cell.detailTextLabel.text = activitytime;
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    
    //calculate the startdatetime_title string
    NSString *trimmedtitle = [[ev title] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *localkey = [[NSString alloc] initWithFormat:@"%@_%@", [Utils formatDateTimeAsStringUTC:[ev startDate]], trimmedtitle];
    
    
    //detect which events are already in salesforce
    
    //NSLog(@"salesforceevents : %@", [self salesforceevents]);
    
    //NSLog(@"Matching for : %@", localkey); 
    
    if([[self salesforceevents] member:localkey] != nil) {
        UIImage *alreadysyncedimage = [UIImage imageNamed:@"datePicker16.gif"];
        cell.imageView.image = alreadysyncedimage;
    }
    else {
        cell.imageView.image = nil;
    }
    
    
    //set the OK image
    /*
    UIImage *okimage = [UIImage imageNamed:@"Ok20x20.png"];
    UIImage *halfokimage = [UIImage imageNamed:@"OkGray20x20.png"];
    UIImage *notokimage = [UIImage imageNamed:@"button_cancel20x20.png"];
    NSString *whatid = [activity fieldValue:@"WhatId"];
    NSString *type = [activity fieldValue:@"Type"];
    
    if([whatid length] == 0 && [type length] == 0) {
        cell.imageView.image = notokimage;
    }
    if([whatid length] != 0 || [type length] != 0 ) {
        cell.imageView.image = halfokimage;
    }
    if([whatid length] != 0 && [type length] != 0 ) {
        cell.imageView.image = okimage;
    }*/
    
    
    
    
    
    
    [localkey release];
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
            [self queryiPadCalendar];
			break;
		case 1:
            self.startdate = [Utils startOfWeek];
            self.enddate = [Utils endOfWeek];
            [self queryiPadCalendar];
			break;
        case 2:
			self.startdate = [Utils addOneWeek:self.startdate];
            self.enddate = [Utils addOneWeek:self.enddate];
            [self queryiPadCalendar];
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
    EKEvent *event = [d.events objectAtIndex:[indexPath row]];
    selectedipadevent = event;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IPADEVENTSELECTED" object:self];
}


//A notification will be dispatched from the detail view to the app delegate, calling this method when an ipad event is saved to salesforce
//ipad event saved to salesforce
-(void)ipadeventsaved:(NSNotification *)notification {
    
    [self queryiPadCalendar];
    [[self tableview] reloadData];
}


@end
