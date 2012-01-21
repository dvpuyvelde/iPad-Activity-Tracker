//
//  CalendarViewController.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 03/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Eventkit/EventKit.h>

@interface AllEventsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    EKEventStore *store;
//    NSMutableArray *ipadevents;
    NSMutableDictionary *week; //contains Day objects, each holding activities in a dictionary
    NSMutableArray *dayheaders; //used to keep track of the headers in each day section of the UITableView
    UISegmentedControl *segmentedControl;
    UITableView *tableview;
//    NSMutableSet *salesforceeventkeys;
//    NSMutableDictionary *salesforceevents;
    EKEvent *selectedipadevent;
    NSMutableDictionary *allevents;
}

//@property (nonatomic, retain) NSMutableArray *ipadevents;
@property (nonatomic, retain) NSMutableDictionary *week;
@property (nonatomic, retain) NSMutableArray *dayheaders;
@property (nonatomic, retain) NSDate *startdate;
@property (nonatomic, retain) NSDate *enddate;
@property (retain, nonatomic) IBOutlet UITableView *tableview;
@property (retain, nonatomic) EKEvent *selectedipadevent;
//@property (retain) NSMutableSet *salesforceeventkeys;
//@property (retain, nonatomic) NSMutableDictionary *salesforceevents;
@property (retain, atomic) NSMutableDictionary *allevents;


-(void)queryForEvents;
- (IBAction)changeWeek:(id)sender;

@end
