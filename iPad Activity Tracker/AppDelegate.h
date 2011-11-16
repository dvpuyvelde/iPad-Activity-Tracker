//
//  AppDelegate.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDCOAuthViewController.h"
#import "ZKQueryResult.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) FDCOAuthViewController *oAuthViewController;

-(void)startApp;
- (void)queryResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
-(void)logout;
-(void)popLoginWindow;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end
