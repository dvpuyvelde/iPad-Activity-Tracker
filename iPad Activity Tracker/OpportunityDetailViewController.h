//
//  OpportunityDetailViewController.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zkSObject.h"
#import "OpportunitySelectController.h"
#import "OpportunitySearchController.h"

@interface OpportunityDetailViewController : UIViewController {
    ZKSObject *opportunity;
    UIViewController *parentviewcontroller;
}

@property (retain, nonatomic) ZKSObject *opportunity;
@property (retain, nonatomic) UIViewController *parentviewcontroller;
@property (retain, nonatomic) IBOutlet UILabel *NameOutlet;
@property (retain, nonatomic) IBOutlet UILabel *OwnerOutlet;
@property (retain, nonatomic) IBOutlet UILabel *CloseDateOutlet;
@property (retain, nonatomic) IBOutlet UILabel *AmountOutlet;
@property (retain, nonatomic) IBOutlet UILabel *AccountOutlet;
@property (retain, nonatomic) IBOutlet UILabel *StageOutlet;

- (IBAction)SelectButtonClicked:(id)sender;

@end
