//
//  AppDelegate.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginView.h"
#import "SFDCEventsView.h"
#import "SFDCEventDetailViewController.h"
#import "CalendarViewController.h"
#import "AllEventsViewController.h"
#import "ZKSforce.h"
#import "SimpleKeychain.h"
#import "ZKSObject.h"
#import "SFDC.h"
#import "Utils.h"

//#define kSFOAuthConsumerKey @"3MVG99OxTyEMCQ3hRUGLgJAnih3VIVuDxxlXj88D.ruS45yi.z0rQG_h0IPlvc66hb3PZ3xNrk3dV1iqRzvsa"

static NSString *OAUTH_CLIENTID = @"3MVG99OxTyEMCQ3hRUGLgJAnih3VIVuDxxlXj88D.ruS45yi.z0rQG_h0IPlvc66hb3PZ3xNrk3dV1iqRzvsa";
static NSString *OAUTH_CALLBACK = @"iPadActivityTracker://login/success";

@implementation AppDelegate

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;
//@synthesize oAuthViewController;
@synthesize _sfdcEventDetailViewController;

- (void)dealloc
{
    [_window release];
    [_splitViewController release];
//    [oAuthViewController release];
    [_sfdcEventDetailViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //initialize the app with the login window
    [self popLoginWindow];
    return YES;
}



//show the OAuth login window
-(void)popLoginWindow {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    LoginView *loginview = [[[LoginView alloc] initWithNibName:@"LoginView" bundle:nil] autorelease];
    self.window.rootViewController = loginview;
    //add a listener for the login event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startApp) name:@"LOGGEDIN" object:loginview];
    
    [self.window makeKeyAndVisible];
}



//This method will start the actual uisplitviewcontroller and child views
-(void)startApp {
   
    // Salesforce events left view
    SFDCEventsView *sfdceventsview = [[[SFDCEventsView alloc] initWithNibName:@"SFDCEventsView" bundle:nil] autorelease];
    [sfdceventsview setTitle:@"Salesforce Agenda"];
    [[sfdceventsview tabBarItem] setImage:[UIImage imageNamed:@"openactivity32.png"]];
    //set the needed observers for events happening in child views
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sfdceventselected:) name:@"SFDCEVENTSELECTED" object:sfdceventsview];

    //iPad calendar left view
    CalendarViewController *calendarview = [[[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil] autorelease];
    [calendarview setTitle:@"iPad Calendar"];
    [[calendarview tabBarItem] setImage:[UIImage imageNamed:@"openactivity32.png"]];
    [calendarview setStartdate:[Utils startOfWeek]];
    [calendarview setEnddate:[Utils endOfWeek]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ipadeventselected:) name:@"IPADEVENTSELECTED" object:calendarview];
    
    //All Events View left (iPad and Salesforce events shown together)
    AllEventsViewController *alleventsview = [[[AllEventsViewController alloc] initWithNibName:@"AllEventsViewController" bundle:nil] autorelease];
    [alleventsview setTitle:@"All Events"];
    [[alleventsview tabBarItem] setImage:[UIImage imageNamed:@"openactivity32.png"]];
    [alleventsview setStartdate:[Utils startOfWeek]];
    [alleventsview setEnddate:[Utils endOfWeek]];
    
    //left tab bar
    UITabBarController *tabbarcontroller = [[[UITabBarController alloc] init] autorelease];
    tabbarcontroller.viewControllers = [NSArray arrayWithObjects:alleventsview, sfdceventsview, calendarview, nil];
    
    
    //Main SFDC Event detail view
    SFDCEventDetailViewController *sfdcEventDetailViewController = [[SFDCEventDetailViewController alloc] initWithNibName:@"SFDCEventDetailViewController" bundle:nil];
    [self set_sfdcEventDetailViewController:sfdcEventDetailViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"LOGOUT" object:sfdcEventDetailViewController];
    [[NSNotificationCenter defaultCenter] addObserver:calendarview selector:@selector(ipadeventsaved:) name:@"IPADEVENTSAVED" object:sfdcEventDetailViewController];
    [[NSNotificationCenter defaultCenter] addObserver:sfdceventsview selector:@selector(sfdceventsaved:) name:@"SFDCEVENTSAVED" object:sfdcEventDetailViewController];
    
    //assemble the views in the splitviewcontroller
    self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
    self.splitViewController.delegate = sfdcEventDetailViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:tabbarcontroller, sfdcEventDetailViewController, nil];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    
}


/*
 EVENT OBSERVER METHODS
 */
//SFDC Event
-(void)sfdceventselected:(NSNotification *)notification {
    SFDCEventsView *eventsview = [notification object];
    ZKSObject *activity = [eventsview selectedsfdcevent];
    //NSLog(@"SFDC EVENT SELECTED : %@", [activity fieldValue:@"Subject"]);  
    [[self _sfdcEventDetailViewController] setActivity:activity];
}

//iPad Calendar Event
-(void)ipadeventselected:(NSNotification *)notification {
    CalendarViewController *eventsview = [notification object];
    EKEvent *event = [eventsview selectedipadevent];
    //NSLog(@"SFDC EVENT SELECTED : %@", [activity fieldValue:@"Subject"]);  
    [[self _sfdcEventDetailViewController] setNewIPadEvent:event];
}

//log out
-(void)logout {
    //nil the refreshtoken.
    [SimpleKeychain delete:@"refreshtoken"];
    [[SFDC sharedInstance] clearCache];
    [self popLoginWindow];
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
