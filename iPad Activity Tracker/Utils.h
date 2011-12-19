//
//  Utils.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 04/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject {
    
}

+(NSString*)formatDateAsString:(NSDate*)date;
+(NSString*)formatDateTimeAsStringUTC:(NSDate*)date;
+(NSDate*)startOfWeek;
+(NSDate*)endOfWeek;
+(NSString*)startOfWeekAsString;
+(NSString*)endOfWeekAsString;
+(NSDate*)addOneWeek:(NSDate*)date;
+(NSDate*)substractOneWeek:(NSDate*)date;
+(NSDate*)dateFromString:(NSString*)str;
+(NSString*)dayDescriptionFromDate:(NSDate*)date;
+(NSString*)descriptionFromString:(NSString*)datestring;

@end
