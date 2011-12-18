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

@implementation CalendarViewController

@synthesize dataRows;
@synthesize week;
@synthesize dayheaders;
@synthesize startdate;
@synthesize enddate;
@synthesize tableview;
//@synthesize selectedsfdcevent;

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
        store = [[EKEventStore alloc] init];
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
    store = nil;
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
    self.dataRows = [store eventsMatchingPredicate:predicate];
    
    
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
    for(EKEvent *activity in [self dataRows]) {
        NSString *dayheader = [Utils dayDescriptionFromDate:[activity startDate]];
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
    for(EKEvent *ev in [self dataRows]) {
        NSLog(@"Event : %@", [ev title]);
    }
    
    NSLog(@"Events fetched");
    

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
    EKEvent *activity = [d.events objectAtIndex:[indexPath row]];
    cell.textLabel.text = [activity title];
    
    //detail text will be the start and end time of the activity
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"HH:mm"];
    NSDate *starttime = [activity startDate];
    NSDate *endtime = [activity endDate];
    NSString *activitytime = [[NSString alloc] initWithFormat:@"%@ - %@", [dtf stringFromDate:starttime],[dtf stringFromDate:endtime]];
    cell.detailTextLabel.text = activitytime;
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    
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


@end
