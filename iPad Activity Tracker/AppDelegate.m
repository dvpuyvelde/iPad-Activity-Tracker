//
//  AppDelegate.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 15/11/11.
//  Copyright (c) 2012 Salesforce.com. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginView.h"
#import "EventDetailViewController.h"
#import "AllEventsViewController.h"
#import "SettingsViewController.h"
#import "ZKSforce.h"
#import "SimpleKeychain.h"
#import "ZKSObject.h"
#import "SFDC.h"
#import "Utils.h"


static NSString *OAUTH_CLIENTID = @"3MVG99OxTyEMCQ3hRUGLgJAnih3VIVuDxxlXj88D.ruS45yi.z0rQG_h0IPlvc66hb3PZ3xNrk3dV1iqRzvsa";
static NSString *OAUTH_CALLBACK = @"iPadActivityTracker://login/success";

@implementation AppDelegate

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;
@synthesize _eventDetailViewController;
@synthesize _alleventsViewController;

- (void)dealloc
{
    [_window release];
    [_splitViewController release];
    [_eventDetailViewController release];
    [_alleventsViewController release];
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
    
    //already start to fetch the default opportunities and types in the background
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [[SFDC sharedInstance] getDefaultActivityTypes];
        dispatch_async( dispatch_get_main_queue(), ^{
            //no notifications. This seems to go fast enough not to cause any issues
        });
    });
    //...and also get the types in the background
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [[SFDC sharedInstance] getDefaultUserOpportunities];
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
        });
    });
    
    //All Events View left (iPad and Salesforce events shown together)
    AllEventsViewController *alleventsview = [[[AllEventsViewController alloc] initWithNibName:@"AllEventsViewController" bundle:nil] autorelease];
    [self set_alleventsViewController:alleventsview];
    [alleventsview setTitle:@"All Events"];
    [[alleventsview tabBarItem] setImage:[UIImage imageNamed:@"database.png"]];
    [alleventsview setStartdate:[Utils startOfWeek]];
    [alleventsview setEnddate:[Utils endOfWeek]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventselected:) name:@"EVENTSELECTED" object:alleventsview];
    
    
    
    //settings view
    SettingsViewController *settingsviewcontroller = [[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil] autorelease];
    [settingsviewcontroller setTitle:@"Settings"];
    [[settingsviewcontroller tabBarItem] setImage:[UIImage imageNamed:@"preferences.png"]];
    [[NSNotificationCenter defaultCenter] addObserver:alleventsview selector:@selector(showsettingschanged:) name:@"SHOWSETTINGSCHANGED" object:settingsviewcontroller];
    
    
    //left tab bar
    UITabBarController *tabbarcontroller = [[[UITabBarController alloc] init] autorelease];
    tabbarcontroller.viewControllers = [NSArray arrayWithObjects:alleventsview, settingsviewcontroller, nil];
    
    
    //Main SFDC Event detail view
    EventDetailViewController *eventDetailViewController = [[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil] autorelease];
    [self set_eventDetailViewController:eventDetailViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"LOGOUT" object:eventDetailViewController];
    [[NSNotificationCenter defaultCenter] addObserver:alleventsview selector:@selector(eventsaved:) name:@"EVENTSAVED" object:eventDetailViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sfdceventdeleted:) name:@"SFDCEVENTDELETED" object:eventDetailViewController];
    
    //assemble the views in the splitviewcontroller
    self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
    self.splitViewController.delegate = eventDetailViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:tabbarcontroller, eventDetailViewController, nil];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    
}


/*
 EVENT OBSERVER METHODS
 */

//ATEvent selected
-(void)eventselected:(NSNotification *)notification {
    AllEventsViewController *alleventsview = [notification object];
    ATEvent *event = [alleventsview selectedevent];
    [[self _eventDetailViewController] setNewEvent:event];
}

//SFDC EVENT DELETED
-(void)sfdceventdeleted:(NSNotification*)notification {
    [[self _alleventsViewController] queryForEvents];
    [[[self _alleventsViewController] tableview] reloadData];
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
