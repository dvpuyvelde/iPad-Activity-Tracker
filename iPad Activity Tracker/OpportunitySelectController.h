//
//  OpportunitySelectController.h
//  Activity Tracker
//
//  Created by David Van Puyvelde on 20/06/11.
//  Copyright 2012 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKSObject.h"


@interface OpportunitySelectController : UITableViewController {
    NSMutableArray *opportunities; //tied to display, might be filtered by searc
    NSMutableArray *allopportunities; //returned from the query
    ZKSObject *selectedopportunity;
    UISearchBar *searchbar;
}
@property (nonatomic, retain) IBOutlet UISearchBar *searchbar;

@property (nonatomic, retain) NSMutableArray *opportunities;
@property (nonatomic, retain) NSMutableArray *allopportunities;
@property (nonatomic, retain) ZKSObject *selectedopportunity;

-(void)selectOpportunity:(ZKSObject*) opp;

@end
