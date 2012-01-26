//
//  CalendarViewController.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 03/12/11.
//  Copyright (c) 2012 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Eventkit/EventKit.h>
#import "ATEvent.h"

@interface AllEventsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    EKEventStore *store;
    NSMutableDictionary *week; //contains Day objects, each holding activities in a dictionary
    NSMutableArray *dayheaders; //used to keep track of the headers in each day section of the UITableView
    UISegmentedControl *segmentedControl;
    UITableView *tableview;
    EKEvent *selectedipadevent;
    ATEvent *selectedevent;
    NSMutableDictionary *allevents;
}

@property (nonatomic, retain) NSMutableDictionary *week;
@property (nonatomic, retain) NSMutableArray *dayheaders;
@property (nonatomic, retain) NSDate *startdate;
@property (nonatomic, retain) NSDate *enddate;
@property (retain, nonatomic) IBOutlet UITableView *tableview;
@property (retain, nonatomic) EKEvent *selectedipadevent;
@property (retain, nonatomic) ATEvent *selectedevent;
@property (retain, atomic) NSMutableDictionary *allevents;


-(void)queryForEvents;
- (IBAction)changeWeek:(id)sender;

@end
