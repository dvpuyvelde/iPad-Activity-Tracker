//
//  SFDCEventsView.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKSObject.h"

@interface SFDCEventsView : UIViewController <UITableViewDelegate, UITableViewDataSource> {

    NSMutableArray *dataRows;
    NSMutableDictionary *week; //contains Day objects, each holding activities in a dictionary
    NSMutableArray *dayheaders; //used to keep track of the headers in each day section of the UITableView
    UISegmentedControl *segmentedControl;
    UITableView *tableview;
    ZKSObject *selectedsfdcevent;
}

@property (nonatomic, retain) NSMutableArray *dataRows;
@property (nonatomic, retain) NSMutableDictionary *week;
@property (nonatomic, retain) NSMutableArray *dayheaders;
@property (nonatomic, retain) NSDate *startdate;
@property (nonatomic, retain) NSDate *enddate;
@property (retain, nonatomic) IBOutlet UITableView *tableview;
@property (retain, nonatomic) ZKSObject *selectedsfdcevent;

- (IBAction)changeWeek:(id)sender;
-(void)queryForActivities;
-(void)setupGroupedTableData:(ZKQueryResult*) result;

@end
