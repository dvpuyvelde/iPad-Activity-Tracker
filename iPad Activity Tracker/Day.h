//
//  Day.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 04/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZKSObject.h"


@interface Day : NSObject {
    NSString *description;
    NSMutableArray *events;
}

@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) NSString *description;

-(void)addEvent:(ZKSObject*)event;

@end
