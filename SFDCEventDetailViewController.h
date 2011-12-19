//
//  SFDCEventDetailViewController.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKSObject.h"
#import <Eventkit/EventKit.h>

@interface SFDCEventDetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {

    ZKSObject *activity;
    EKEvent *ipadevent;
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
@property (nonatomic, retain) EKEvent *ipadevent;
@property (nonatomic, retain) IBOutlet UILabel *starttimeoutlet;
@property (nonatomic, retain) IBOutlet UILabel *endtimeoutlet;
@property (nonatomic, retain) IBOutlet UILabel *relatedtooutlet;
@property (nonatomic, retain) IBOutlet UILabel *typeoutlet;
@property (nonatomic, retain) IBOutlet UITextView *descriptiontextoutlet;
@property (nonatomic, retain) IBOutlet UILabel *subjectoutlet;
@property (nonatomic, retain) IBOutlet UILabel *locationoutlet;
@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navigationbartitle;
@property (retain, nonatomic) IBOutlet UILabel *RelatedToLabel;
@property (retain, nonatomic) IBOutlet UILabel *TypeLabel;
@property (retain, nonatomic) IBOutlet UIButton *SaveToSalesforceButtonOutlet;

- (IBAction)logoutButtonClicked:(id)sender;
-(void) setNewIPadEvent:(EKEvent *)newEvent;
- (IBAction)saveToSalesforceClicked:(id)sender;

@end
