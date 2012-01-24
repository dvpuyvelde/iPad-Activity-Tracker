//
//  ATEvent.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 11/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Eventkit/EventKit.h>
#import "ZKSforce.h"

@interface ATEvent : NSObject {
    NSString *comparekey;
    NSString *sfdcid;
    NSString *ekeventid;
    NSDate *startdate;
    NSDate *enddate;
    NSString *duration;
    NSString *subject;
    NSString *location;
    NSString *description;
    NSString *type;
    NSString *whatid;
    NSString *what;
}

@property (nonatomic, retain) NSString *comparekey;
@property (nonatomic, retain) NSString *sfdcid;
@property (nonatomic, retain) NSString *ekeventid;
@property (nonatomic, retain) NSDate *startdate;
@property (nonatomic, retain) NSDate *enddate;
@property (nonatomic, retain) NSString *duration;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *whatid;
@property (nonatomic, retain) NSString *what;

-(BOOL)isIpadEvent;
-(BOOL)isSFDCEvent;
-(void)withEKEvent:(EKEvent*) ekevent;
-(void)withSFDCEvent:(ZKSObject*) sfdcevent;

@end
