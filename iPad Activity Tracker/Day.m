//
//  Day.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 04/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Day.h"
#import "Utils.h"


@implementation Day

@synthesize events;
@synthesize description;


-(void)addEvent:(NSObject*)event {
    if(!events) {
        events = [[NSMutableArray alloc] init];
    }
    //NSString *daydescription = [Utils dayDescriptionFromDate:[Utils dateFromString:[event fieldValue:@"ActivityDate"]]];
    //[[self events] setObject:event forKey:daydescription];
    [[self events] addObject:event];
}

-(void)dealloc {
    [description release];
    [events release];
    [super dealloc];
}

@end
