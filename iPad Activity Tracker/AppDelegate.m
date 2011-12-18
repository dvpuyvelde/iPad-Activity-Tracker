//
//  AppDelegate.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "LoginView.h"
#import "SFDCEventsView.h"
#import "SFDCEventDetailViewController.h"
#import "CalendarViewController.h"
#import "ZKSforce.h"
#import "FDCServerSwitchboard.h"
#import "ZKSObject.h"

#define kSFOAuthConsumerKey @"3MVG99OxTyEMCQ3hRUGLgJAnih3VIVuDxxlXj88D.ruS45yi.z0rQG_h0IPlvc66hb3PZ3xNrk3dV1iqRzvsa"


@implementation AppDelegate

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;
@synthesize oAuthViewController;
@synthesize _sfdcEventDetailViewController;

- (void)dealloc
{
    [_window release];
    [_splitViewController release];
    [oAuthViewController release];
    [_sfdcEventDetailViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //initialize the app with the login window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    LoginView *loginview = [[[LoginView alloc] initWithNibName:@"LoginView" bundle:nil] autorelease]
    ;
    self.window.rootViewController = loginview;
    
    [self.window makeKeyAndVisible];
    
    //if we already have a refreshtoken, just set it and don't log in
    NSString *refreshtoken = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshToken"];
    if(refreshtoken) {
        [[FDCServerSwitchboard switchboard] setClientId:kSFOAuthConsumerKey];
        [[FDCServerSwitchboard switchboard] setApiUrlFromOAuthInstanceUrl:[[NSUserDefaults standardUserDefaults] valueForKey:@"apiUrlFromOAuthInstanceUrl"]];
        [[FDCServerSwitchboard switchboard] setSessionId:[[NSUserDefaults standardUserDefaults] valueForKey:@"sessionId"]];
        [[FDCServerSwitchboard switchboard] setOAuthRefreshToken:refreshtoken];
        
        [[FDCServerSwitchboard switchboard] getUserInfoWithTarget:self selector:@selector(userInfoResult:) context:nil];
        
        //[self startApp]; we'll do this after we have the userinfo object returned
        return YES;
    }
    
    [self popLoginWindow];
    

    
    return YES;
}

//show the OAuth login window
-(void)popLoginWindow {
    oAuthViewController = [[FDCOAuthViewController alloc] initWithTarget:self selector:@selector(loginOAuth:error:) clientId:kSFOAuthConsumerKey];
    oAuthViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    //[mainViewController presentModalViewController:oAuthViewController animated:YES];
    [self.window.rootViewController presentModalViewController:oAuthViewController animated:YES];
}


//do the login
- (void)loginOAuth:(FDCOAuthViewController *)oAuthViewController error:(NSError *)error
{
    if ([[self oAuthViewController] accessToken] && !error)
    {
        [[FDCServerSwitchboard switchboard] setClientId:kSFOAuthConsumerKey];
        [[FDCServerSwitchboard switchboard] setApiUrlFromOAuthInstanceUrl:[[self oAuthViewController] instanceUrl]];
        [[FDCServerSwitchboard switchboard] setSessionId:[[self oAuthViewController] accessToken]];
        [[FDCServerSwitchboard switchboard] setOAuthRefreshToken:[[self oAuthViewController] refreshToken]];
        [[[self window] rootViewController] dismissModalViewControllerAnimated:YES];
        
        
        [[self oAuthViewController] autorelease];
        
        //save all the authentication info for later re-use (oauth)
        FDCOAuthViewController *vc = [self oAuthViewController];
        [[NSUserDefaults standardUserDefaults] setValue:[vc refreshToken] forKey:@"refreshToken"];
        [[NSUserDefaults standardUserDefaults] setValue:[vc instanceUrl] forKey:@"apiUrlFromOAuthInstanceUrl"];
        [[NSUserDefaults standardUserDefaults] setValue:[vc accessToken] forKey:@"sessionId"];
        
        [self startApp];
        
    }
    else if (error)
    {
        NSLog(@"An error occurred while trying to login.");
    }
}

-(void)userInfoResult:(ZKUserInfo *)result {
    NSLog(@"%@", [result userId]);
    [[FDCServerSwitchboard switchboard] setUserInfo:result];
    [self startApp];
}

//log out
-(void)logout {
    //nil the refreshtoken.
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"refreshToken"];
    [self popLoginWindow];
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
    
    //left tab bar
    UITabBarController *tabbarcontroller = [[[UITabBarController alloc] init] autorelease];
    tabbarcontroller.viewControllers = [NSArray arrayWithObjects:sfdceventsview, calendarview, nil];
    
    //DetailViewController *detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
    
    //Main SFDC Event detail view
    SFDCEventDetailViewController *sfdcEventDetailViewController = [[SFDCEventDetailViewController alloc] initWithNibName:@"SFDCEventDetailViewController" bundle:nil];
    [self set_sfdcEventDetailViewController:sfdcEventDetailViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"LOGOUT" object:sfdcEventDetailViewController];
    
    //log out button and notification
    //UIBarButtonItem *logoutbutton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    //[[sfdcEventDetailViewController navigationItem] setRightBarButtonItem:logoutbutton];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"logout" object:sfdcEventDetailViewController];
    
    //assemble the views in the splitviewcontroller
    self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
    self.splitViewController.delegate = sfdcEventDetailViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:tabbarcontroller, sfdcEventDetailViewController, nil];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    
    //[logoutbutton release];
}


/*
 EVENT OBSERVER METHODS
 */
-(void)sfdceventselected:(NSNotification *)notification {
    SFDCEventsView *eventsview = [notification object];
    ZKSObject *activity = [eventsview selectedsfdcevent];
    NSLog(@"SFDC EVENT SELECTED : %@", [activity fieldValue:@"Subject"]);  
    [[self _sfdcEventDetailViewController] setActivity:activity];
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
