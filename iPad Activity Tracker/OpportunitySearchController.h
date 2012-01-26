//
//  OpportunitySearchController.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 25/01/12.
//  Copyright (c) 2012 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import "zkSObject.h"

@interface OpportunitySearchController : UITableViewController {
    UISearchBar *searchbar;
    NSMutableArray *opportunities;
    ZKSObject *selectedopportunity;
}

@property (retain, nonatomic) IBOutlet UISearchBar *searchbar;
@property (retain, nonatomic) NSMutableArray *opportunities;
@property (retain, nonatomic) ZKSObject *selectedopportunity;

-(void)selectOpportunity:(ZKSObject*) opp;

@end
