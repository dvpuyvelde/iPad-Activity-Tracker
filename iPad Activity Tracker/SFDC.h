//
//  SFDC.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 21/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zkSforce.h"

@interface SFDC : NSObject {
    ZKSforceClient *client;
    NSMutableArray *activitytypes;
    NSMutableArray *useropportunities;
}

@property (nonatomic, retain) ZKSforceClient *client;
@property (nonatomic, retain) NSMutableArray *activitytypes;
@property (readonly, nonatomic, retain) NSMutableArray *useropportunities;

+ (SFDC *)sharedInstance;
-(NSMutableArray *)getDefaultActivityTypes;
-(NSMutableArray *) getDefaultUserOpportunities;
-(void)clearCache;


@end
