//
//  SFDCEventsView.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SFDCEventsView.h"
#import <UIKit/UIKit.h>
#import "ZKSforce.h"
#import "Utils.h"
#import "Day.h"
#import "zkSforce.h"
#import "zkUserInfo.h"
#import "SFDC.h"

@implementation SFDCEventsView


@synthesize dataRows;
@synthesize week;
@synthesize dayheaders;
@synthesize startdate;
@synthesize enddate;
@synthesize tableview;
@synthesize selectedsfdcevent;

- (void)dealloc
{
    [week release];
    [dayheaders release];
    [startdate release];
    [enddate release];
    [dataRows release];
    [tableview release];
    //[selectedsfdcevent release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    //initialize the start and end date
    self.startdate = [Utils startOfWeek];
    self.enddate = [Utils endOfWeek];
    [self queryForActivities];
}

- (void)viewDidUnload
{
    [self setTableview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

/*
 GET THE ACTIVITIES
 */
-(void)queryForActivities {
    ZKSforceClient *client = [[SFDC sharedInstance] client];
    
    ZKUserInfo *userinfo = [client currentUserInfo];
    
    //build the activities query
    NSString *activitiesQuery = [[NSString alloc ] initWithFormat:@"SELECT Id, ActivityDate, WhatId, StartDateTime,EndDateTime, Subject, Location, Description, OwnerId, Type, What.Name FROM Event where OwnerId ='%@' and ActivityDate >=%@ and ActivityDate <=%@ order by StartDateTime limit 200", [userinfo userId], [Utils formatDateAsString:startdate], [Utils formatDateAsString:enddate]];
    
    //NSLog(@"Activities Query : %@", activitiesQuery);
    
    /*
     // run the query in the background thread, when its done, update the ui.
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
     ZKQueryResult *qr = [_client query:@"select id,name from account order by SystemModstamp desc LIMIT 50"];
     dispatch_async(dispatch_get_main_queue(), ^(void) {
     self.results = qr;
     [[self tableView] reloadData];
     });
     });
     */
    
    
    
    //@try {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            ZKQueryResult *result = [client query:activitiesQuery];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                self.dataRows = [NSMutableArray arrayWithArray:[result records]];
                [self setupGroupedTableData:result];
            });
        });
        
         
        
        
        
    /*}
    //@catch (NSException *exception) {
        NSLog(@"handle error");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: [exception description]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }*/
}


//rearrange the data in days and events
-(void)setupGroupedTableData:(ZKQueryResult*) result {
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
    for(ZKSObject *activity in [result records]) {
        NSString *dayheader = [Utils descriptionFromString:[activity fieldValue:@"ActivityDate"]];
        //add the dayheader for the UITableView Sections
        if(![dayheaders containsObject:dayheader]) [dayheaders addObject:dayheader];
        
        //if there's no day in the week array yet, create one, add a day and set the first activity in that day
        if([week count] == 0) {
            Day *d = [[Day alloc] init];
            d.description = dayheader;
            [d addEvent:activity];
            [week setObject:d forKey:dayheader];
            [d release];
            continue;
        }
        //if the last activity of the last day in the week array is already there, add this activity to that day
        //Day *compareday = [week objectForKey:dayheader];
        if([week objectForKey:dayheader]) {
            [[week objectForKey:dayheader] addEvent:activity];
        }
        //if it isn't, create a new Day and add the event to that
        else {
            Day *d = [[Day alloc] init];
            d.description = dayheader;
            [d addEvent:activity];
            [week setObject:d forKey:dayheader];
            [d release];
        }
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
    
    // Return the number of rows in the section.
    return [[[week objectForKey:dayheader] events] count];;
}





/*
 TABLE CELL RENDERING
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(!week) return cell;
    
    // Configure the cell...
    NSString *dayheader = [dayheaders objectAtIndex:[indexPath section]];
    Day *d = [week objectForKey:dayheader];
    //cell.textLabel.text = [[self.dataRows objectAtIndex:[indexPath row]] fieldValue:@"Subject"];
    ZKSObject *activity = [d.events objectAtIndex:[indexPath row]];
    cell.textLabel.text = [activity fieldValue:@"Subject"];
    
    //detail text will be the start and end time of the activity
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"HH:mm"];
    NSDate *starttime = [activity dateTimeValue:@"StartDateTime"];
    NSDate *endtime = [activity dateTimeValue:@"EndDateTime"];
    NSString *activitytime = [[NSString alloc] initWithFormat:@"%@ - %@", [dtf stringFromDate:starttime],[dtf stringFromDate:endtime]];
    cell.detailTextLabel.text = activitytime;
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    
    //set the OK image
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
    }
    
    
    
    
    //[okimage release];
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
            [self queryForActivities];
			break;
		case 1:
            self.startdate = [Utils startOfWeek];
            self.enddate = [Utils endOfWeek];
            [self queryForActivities];
			break;
        case 2:
			self.startdate = [Utils addOneWeek:self.startdate];
            self.enddate = [Utils addOneWeek:self.enddate];
            [self queryForActivities];
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
    ZKSObject *activity = [d.events objectAtIndex:[indexPath row]];
    selectedsfdcevent = activity;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SFDCEVENTSELECTED" object:self];
}


/*
 Notified when the SFDC event is saved, this needs to refresh the list
 */
-(void)sfdceventsaved:(NSNotification*)notification {
    [self queryForActivities];
}

@end
