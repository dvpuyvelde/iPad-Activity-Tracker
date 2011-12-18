//
//  SFDCEventDetailViewController.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKSObject.h"

@interface SFDCEventDetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {

    ZKSObject *activity;
    UILabel *_starttimeoutlet;
    UILabel *_endtimeoutlet;
    UILabel *_relatedtooutlet;
    //UILabel *_descriptionoutlet;
    UITextView *_descriptiontextoutlet;
    UILabel *_subjectoutlet;
    UILabel *_locationoutlet;
    UILabel *_typeoutlet;
}

@property (nonatomic, retain) ZKSObject *activity;
@property (nonatomic, retain) IBOutlet UILabel *starttimeoutlet;
@property (nonatomic, retain) IBOutlet UILabel *endtimeoutlet;
@property (nonatomic, retain) IBOutlet UILabel *relatedtooutlet;
@property (nonatomic, retain) IBOutlet UILabel *typeoutlet;
@property (nonatomic, retain) IBOutlet UITextView *descriptiontextoutlet;
@property (nonatomic, retain) IBOutlet UILabel *subjectoutlet;
@property (nonatomic, retain) IBOutlet UILabel *locationoutlet;
@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navigationbartitle;
- (IBAction)logoutButtonClicked:(id)sender;

@end
