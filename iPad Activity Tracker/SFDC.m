//
//  SFDC.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 21/12/11.
//  Copyright (c) 2012 Salesforce.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFDC.h"


@implementation SFDC

@synthesize client;
@synthesize activitytypes;
@synthesize useropportunities;

/*
 GET THE ACTIVITY TYPES BASED ON DEFAULT RECORD TYPE
 */
-(NSMutableArray*)getDefaultActivityTypes {
    //if we already have 'm, just return 'm
    if([self activitytypes]) return [self activitytypes];
    //query if we don't
    if([self client] != nil) {
        self.activitytypes = [[[NSMutableArray alloc] init] autorelease];
        ZKDescribeLayoutResult *dlr = [[self client] describeLayout:@"Event" recordTypeIds:nil];
        for(ZKRecordTypeMapping *mapping in [dlr recordTypeMappings]) {
            if([mapping defaultRecordTypeMapping] == TRUE) {
                //NSLog(@"Mapping : %@", [mapping name]);
                NSArray *picklistsforrecordtype = [mapping picklistsForRecordType];
                for(ZKPicklistForRecordType *pfrt in picklistsforrecordtype) {                
                    if([[pfrt picklistName] isEqualToString:@"Type"]) {
                        //NSLog(@"Picklist : %@", [pfrt picklistName]);
                        for(ZKPicklistEntry *ple in [pfrt picklistValues]) {
                            //NSLog(@" -------> %@", [ple value]);
                            [[self activitytypes] addObject:[ple value]];
                        }
                    }
                }
            }
        }
    }
    return [self activitytypes];
}

/*
    GET THE DEFAULT OPPORTUNITIES TO SHOW
 */
-(NSMutableArray *) getDefaultUserOpportunities {
    //if we already have'm just return 'm
    if([self useropportunities]) return useropportunities;

    //query if we don't
    useropportunities = [[NSMutableArray alloc] init];
    NSString *userid = [[client currentUserInfo] userId];
    NSString *username = [[client currentUserInfo] userName];
    
    @try {
        
        //Query to get the Id's of the opportunities the user is subscribed to in Chatter, can't get this to work in a sub query so I'll get those first
        NSString *subscribedopportunitiesQuery = [[NSString alloc ] initWithFormat:@"SELECT CreatedById, Id, ParentId, Parent.Name, SubscriberId FROM EntitySubscription where SubscriberId = '%@' and Parent.Type = 'Opportunity' limit 1000", userid];
    
        NSMutableArray *subscribedopportunityids = [[NSMutableArray alloc] init];
        //get the subscribed to opportunities
        ZKQueryResult *subscriptionresult = [client query:subscribedopportunitiesQuery];
        for(ZKSObject *record in subscriptionresult.records) {
            [subscribedopportunityids addObject:[record fieldValue:@"ParentId"]];
        }
        NSString *oppidslist = [NSString stringWithFormat:@"'%@'", [subscribedopportunityids componentsJoinedByString:@"','"]];
        
        //this will only work in Org62  get the id's of opportunities where currentuser is on the opp team
        NSString *oppdetailsquery;
        
        if([username hasSuffix:@"@salesforce.com"]) {
            NSString *teamopportunityidsQuery = [NSString stringWithFormat:@"Select sfbase__Opportunity__c From sfbase__OpportunityTeam__c where sfbase__User__c = '%@' and sfbase__Opportunity__r.isClosed = false", userid];
            NSMutableArray *teamopportunityidsarray = [[NSMutableArray alloc] init];
            //the the user's tam opportunities
            ZKQueryResult *teamresult = [client query:teamopportunityidsQuery];
            for(ZKSObject *record in teamresult.records) {
                [teamopportunityidsarray addObject:[record fieldValue:@"sfbase__Opportunity__c"]];
            }
            NSString *teamoppidlist = [NSString stringWithFormat:@"'%@'", [teamopportunityidsarray componentsJoinedByString:@"','"]];

            //build the Org62 opportunitites query
            oppdetailsquery = [NSString stringWithFormat:@"select Id, Name, Account.Name, Owner.Name, CloseDate, IsClosed, StageName, Amount, CurrencyIsoCode from Opportunity where (Id IN (%@) or Id IN (%@)) and IsClosed = false order by Name", teamoppidlist, oppidslist];
            }
            else {
                //build the opportunitites query
                oppdetailsquery = [NSString stringWithFormat:@"select Id, Name, Account.Name, Owner.Name, CloseDate, IsClosed, StageName, Amount from Opportunity where Id IN (%@) and IsClosed = false order by Name", oppidslist];
            }
    
        //NSLog(@"OPPORTUNITY QUERY : %@",oppdetailsquery);
    
    
        ZKQueryResult *result = [client query:oppdetailsquery];
        
        for(ZKSObject *obj in [result records]) {
            //NSLog(@"Opportunity : %@", [obj fieldValue:@"Name"]);
            [[self useropportunities] addObject:obj];
                
        }
        return [self useropportunities];
    }
    @catch (NSException *exception) {
        NSLog(@"Error querying opportunities : %@", [exception description]);
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: [exception description]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return nil;
    }
    
    
    
    //[teamopportunityids release];
    //[oppdetailsquery release];
    
    
}



/*
    CLEAR CACHEDOBJECTS
 */
-(void)clearCache {
    useropportunities = nil;
    self.activitytypes = nil;
}


//SINGLETON BOILERPLATE BELOW

static SFDC *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (SFDC *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    
    if (self) {
        // Work your initialising magic here as you normally would
        
    }
    
    return self;
}

// Your dealloc method will never be called, as the singleton survives for the duration of your app.
// However, I like to include it so I know what memory I'm using (and incase, one day, I convert away from Singleton).
-(void)dealloc
{
    // I'm never called!
    [activitytypes release];
    [useropportunities release];
    [super dealloc];
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [[self sharedInstance] retain];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// Once again - do nothing, as we don't have a retain counter for this object.
- (id)retain {
    return self;
}

// Replace the retain counter so we can never release this object.
- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

// This function is empty, as we don't want to let the user release this object.
- (oneway void)release {
    
}

//Do nothing, other than return the shared instance - as this is expected from autorelease.
- (id)autorelease {
    return self;
}

@end