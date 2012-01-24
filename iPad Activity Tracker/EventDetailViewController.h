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
#import "ATEvent.h"

@interface EventDetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {

//    ZKSObject *activity;
//    EKEvent *ipadevent;
    ATEvent *atevent;
    UILabel *_starttimeoutlet;
    UILabel *_endtimeoutlet;
    UILabel *_relatedtooutlet;
    //UILabel *_descriptionoutlet;
    UITextView *_descriptiontextoutlet;
    UILabel *_subjectoutlet;
    UILabel *_locationoutlet;
    UILabel *_typeoutlet;
    BOOL isipadevent;
    BOOL issfdcevent;
    UIPopoverController *popoverController;
    EKEventStore *store;
//    NSString *selectedwhatid;
//    NSString *selectedwhat;
//    NSString *selectedtype;
}

//@property (nonatomic, retain) ZKSObject *activity;
//@property (nonatomic, retain) EKEvent *ipadevent;
@property (nonatomic, retain) ATEvent *atevent;
@property (nonatomic, retain) IBOutlet UILabel *starttimeoutlet;
@property (nonatomic, retain) IBOutlet UILabel *endtimeoutlet;
@property (nonatomic, retain) IBOutlet UILabel *relatedtooutlet;
@property (nonatomic, retain) IBOutlet UILabel *typeoutlet;
@property (nonatomic, retain) IBOutlet UITextView *descriptiontextoutlet;
@property (nonatomic, retain) IBOutlet UILabel *subjectoutlet;
@property (nonatomic, retain) IBOutlet UILabel *locationoutlet;
@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navigationbartitle;
//@property (retain, nonatomic) IBOutlet UILabel *RelatedToLabel;
@property (retain, nonatomic) IBOutlet UILabel *TypeLabel;
@property (retain, nonatomic) IBOutlet UIButton *SaveToSalesforceButtonOutlet;
@property (nonatomic, retain) UIPopoverController *popoverController;
//@property (nonatomic, retain) NSString *selectedwhatid;
//@property (nonatomic, retain) NSString *selectedwhat;
//@property (nonatomic, retain) NSString *selectedtype;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *DeleteFromSalesforceButtonOutlet;
@property (retain, nonatomic) IBOutlet UIImageView *ImageCalendarTypeOutlet;
@property (retain, nonatomic) IBOutlet UIWebView *WebView;
- (IBAction)HomeButtonClicked:(id)sender;

- (IBAction)logoutButtonClicked:(id)sender;
//-(void) setNewIPadEvent:(EKEvent *)newEvent;
-(void) setNewEvent:(ATEvent *)newEvent;
- (IBAction)saveToSalesforceClicked:(id)sender;
- (IBAction)TypeButtonTouched:(id)sender;
- (IBAction)RelatedToButtonTouched:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;

@end
