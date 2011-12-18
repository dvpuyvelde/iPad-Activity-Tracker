//
//  Utils.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 04/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"


@implementation Utils

//return a NSDate as NSString in YYYY-MM-DD format
+(NSString*)formatDateAsString:(NSDate*)date {
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    //Set the required date format
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //Get the string date
    return [formatter stringFromDate:date];
}

//get the start of the current week as string
+(NSString*)startOfWeekAsString {
    return [self formatDateAsString:[self startOfWeek]];
}

+(NSDate*)startOfWeek {
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDate *today = [NSDate date];
    NSDate *beginningOfWeek = nil;
    [gregorian rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek
                  interval:NULL forDate: today];
    return beginningOfWeek;
}

//get the end of the current week as NSDate
+(NSDate*)endOfWeek {
    NSDate *startdate = [self startOfWeek];
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    [components setDay:7];
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    
    NSDate *endofweek = [gregorian dateByAddingComponents:components toDate:startdate options:0];
    return endofweek;
}

//get the end of the week as nsstring
+(NSString*)endOfWeekAsString {
    
    return [self formatDateAsString:[self endOfWeek]];
}


//add one week to a date
+(NSDate*)addOneWeek:(NSDate *)date {
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    [components setDay:7];
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    
    NSDate *oneweeklater = [gregorian dateByAddingComponents:components toDate:date options:0];
    return oneweeklater;
}

//go one week in the past
+(NSDate*)substractOneWeek:(NSDate *)date {
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    [components setDay:-7];
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    
    NSDate *oneweekearlier = [gregorian dateByAddingComponents:components toDate:date options:0];
    return oneweekearlier;
}

//get a date from an NSString yyyy-mm-dd
+(NSDate*)dateFromString:(NSString*)str {
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:str];
    return date;
}

//get a day and date string from NSDate
+(NSString*)dayDescriptionFromDate:(NSDate*)date {
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"EEEE MMMM d"];
    NSString *dateStr = [dateFormat stringFromDate:date];  
    return dateStr;
}

//provide a full description from the YYYY-MM-DD string (Sunday June 19)
+(NSString*)descriptionFromString:(NSString*)datestring {
    return [self dayDescriptionFromDate:[self dateFromString:datestring]];
}

@end
