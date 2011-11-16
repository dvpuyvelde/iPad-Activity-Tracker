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
#import "FDCServerSwitchboard.h"
#import "ZKSObject.h"

#define kSFOAuthConsumerKey @"3MVG99OxTyEMCQ3hRUGLgJAnih3VIVuDxxlXj88D.ruS45yi.z0rQG_h0IPlvc66hb3PZ3xNrk3dV1iqRzvsa"


@implementation AppDelegate

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;
@synthesize oAuthViewController;

- (void)dealloc
{
    [_window release];
    [_splitViewController release];
    [oAuthViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //initialize the app with the login window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    LoginView *loginview = [[[LoginView alloc] initWithNibName:@"LoginView" bundle:nil] autorelease]
    ;
    self.window.rootViewController = loginview;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedin:) name:@"LoggedIn" object:loginview];
    
    [self.window makeKeyAndVisible];
    
    //if we already have a refreshtoken, just set it and don't log in
    NSString *refreshtoken = [[NSUserDefaults standardUserDefaults] valueForKey:@"refreshToken"];
    if(refreshtoken) {
        [[FDCServerSwitchboard switchboard] setClientId:kSFOAuthConsumerKey];
        [[FDCServerSwitchboard switchboard] setApiUrlFromOAuthInstanceUrl:[[NSUserDefaults standardUserDefaults] valueForKey:@"apiUrlFromOAuthInstanceUrl"]];
        [[FDCServerSwitchboard switchboard] setSessionId:[[NSUserDefaults standardUserDefaults] valueForKey:@"sessionId"]];
        [[FDCServerSwitchboard switchboard] setOAuthRefreshToken:refreshtoken];
        
        //[[FDCServerSwitchboard switchboard] query:@"select Id, Name from Account" target:self selector:@selector(queryResult:error:context:) context:nil];    
        [self startApp];
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

//log out
-(void)logout {
    //nil the refreshtoken.
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"refreshToken"];
    [self popLoginWindow];
}

/*
- (void)queryResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSLog(@"result came back");
    if (result && !error)
    {
        NSArray *results = [result records];
        for(ZKSObject *obj in results) {
            NSLog(@"%@",[obj fieldValue:@"Name"]);
        }
    }
    else if (error)
    {
        NSLog(@"handle error");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: [[error userInfo] objectForKey:@"faultstring"]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
*/


//log in observer will fire this method when the loginview signals a successful login
/*
-(void)loggedin:(NSNotification *) notification {
    LoginView *lv = [notification object];
    NSLog(@"Username : %@", [[lv usernameTextField] text]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self startApp];
}
*/


//This method will start the actual uisplitviewcontroller and child views
-(void)startApp {
   
    // Override point for customization after application launch.
    
    //MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil] autorelease];
    SFDCEventsView *sfdceventsview = [[[SFDCEventsView alloc] initWithNibName:@"SFDCEventsView" bundle:nil] autorelease];
    //UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:sfdceventsview] autorelease];
    
    DetailViewController *detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
    //UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailViewController] autorelease];
    UIBarButtonItem *logoutbutton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    
    [[detailViewController navigationItem] setRightBarButtonItem:logoutbutton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"logout" object:detailViewController];
    
    self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
    self.splitViewController.delegate = detailViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:sfdceventsview, detailViewController, nil];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    
    [logoutbutton release];
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
