//
//  AppDelegate.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FDCOAuthViewController.h"
#import "SFDCEventDetailViewController.h"
#import "ZKQueryResult.h"
#import "ZKUserInfo.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

//@property (strong, nonatomic) FDCOAuthViewController *oAuthViewController;
@property (strong, nonatomic) SFDCEventDetailViewController *_sfdcEventDetailViewController;

-(void)startApp;
-(void)logout;
-(void)popLoginWindow;
-(void)sfdceventselected:(NSNotification *) notification;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end
