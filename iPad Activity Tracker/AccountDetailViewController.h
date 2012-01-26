//
//  AccountDetailViewController.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 25/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zkSObject.h"
#import "AccountSelectController.h"

@interface AccountDetailViewController : UIViewController {
    ZKSObject* account;
    AccountSelectController *parentviewcontroller;
}

@property (retain, nonatomic) ZKSObject *account;
@property (retain, nonatomic) AccountSelectController *parentviewcontroller;
@property (retain, nonatomic) IBOutlet UILabel *NameOutlet;
@property (retain, nonatomic) IBOutlet UILabel *OwnerOutlet;
@property (retain, nonatomic) IBOutlet UILabel *StreetOutlet;
@property (retain, nonatomic) IBOutlet UILabel *CityOutlet;
@property (retain, nonatomic) IBOutlet UILabel *CountryOutlet;
- (IBAction)SelectButtonClicked:(id)sender;

@end
