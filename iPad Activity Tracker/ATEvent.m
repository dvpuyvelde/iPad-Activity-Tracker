//
//  ATEvent.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 11/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ATEvent.h"
#import "Utils.h"


@implementation ATEvent

@synthesize subject, startdate, enddate, what, type, description, location, whatid, sfdcid, duration, comparekey;

/*
 is this an iPad only event (no sfdc id)
 */
-(BOOL)isIpadEvent {
    if(self.sfdcid == nil) { return YES; }
    else { return NO; }
}

/*
 ... or and sfdc synced event (has an id)
 */
-(BOOL)isSFDCEvent {
    return ![self isIpadEvent];
}

/*
 populate this ATEvent from an EKEvent (= ipad event)
 */
-(void)withEKEvent:(EKEvent *)ekevent {
    
    //calculate the comparekey (ipad and sfdc events are compared via a 'fake' key : startdatetime_subject
    NSString *trimmedtitle = [[ekevent title] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.comparekey = [[NSString alloc] initWithFormat:@"%@_%@", [Utils formatDateTimeAsStringUTC:[ekevent startDate]], trimmedtitle];
    self.startdate = [ekevent startDate];
    self.enddate = [ekevent endDate];
    self.subject = [ekevent title];
    self.location = [ekevent location];
    self.description = [ekevent notes];
    //calculate meeting length = duration. SFDC will need this when saving an Event object
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    NSDateComponents *breakdowninfo = [sysCalendar components:NSMinuteCalendarUnit fromDate:[ekevent startDate] toDate:[ekevent endDate] options:0];
    NSInteger minutes = [breakdowninfo minute];
    self.duration = [NSString stringWithFormat:@"%d", minutes];
    
    //[trimmedtitle release];
}

/*
 populate this ATEvent from a ZKSobject ( = SFDC object of type 'Event' )
 */
-(void)withSFDCEvent:(ZKSObject *)sfdcevent {
    //let's create a fake key to compare : startdatetimeinutc_subject
    NSString *eventkey = [[[NSString alloc ] initWithFormat:@"%@_%@", [sfdcevent fieldValue:@"ActivityDateTime"], [sfdcevent fieldValue:@"Subject"]] autorelease];
    self.comparekey = eventkey;
    self.sfdcid = [sfdcevent fieldValue:@"Id"];
    self.startdate = [sfdcevent dateTimeValue:@"ActivityDateTime"];
    self.enddate = [sfdcevent dateTimeValue:@"EndDateTime"];
    self.subject = [sfdcevent fieldValue:@"Subject"];
    self.location = [sfdcevent fieldValue:@"Location"];
    self.description = [sfdcevent fieldValue:@"Description"];
    self.duration = [sfdcevent fieldValue:@"DurationInMinutes"];
    self.what = [sfdcevent fieldValue:@"What"];
    self.whatid = [sfdcevent fieldValue:@"WhatId"];
    
    [eventkey release];
}




@end
