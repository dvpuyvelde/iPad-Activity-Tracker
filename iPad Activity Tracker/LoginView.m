//
//  LoginView.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 15/11/11.
//  Copyright (c) 2012 Salesforce.com. All rights reserved.
//

#import "LoginView.h"
#import "zkSforceClient.h"
#import "zkQueryResult.h"
#import "zkUserInfo.h"
#import "SFDC.h"
#import "NSURL+Additions.h"
#import "SimpleKeychain.h"

static NSString *OAUTH_CLIENTID = @"3MVG99OxTyEMCQ3hRUGLgJAnih3VIVuDxxlXj88D.ruS45yi.z0rQG_h0IPlvc66hb3PZ3xNrk3dV1iqRzvsa";
static NSString *OAUTH_CALLBACK = @"iPadActivityTracker://login/success";

@implementation LoginView
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //if we already have a refresh token, use that to log in and don't ask again
    NSString *refreshtoken = [SimpleKeychain load:@"refreshtoken"];
    NSURL *instanceurl = [NSURL URLWithString:[SimpleKeychain load:@"instanceurl"]];

    
    if(refreshtoken) {
        @try {
            ZKSforceClient *client = [[[ZKSforceClient alloc] init] autorelease];
            [client loginWithRefreshToken:refreshtoken authUrl:instanceurl oAuthConsumerKey:OAUTH_CLIENTID];
            [[SFDC sharedInstance] setClient:client];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGGEDIN" object:self];
            return;
        }
        @catch (NSException *exception) {
             
                //if anything else goes wrong here, remove the refresh token so user don't get stuck
                [SimpleKeychain delete:@"refreshtoken"];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Error"
                                      message: [exception description]
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles: nil];
                [alert show];
                [alert release];
        }
    }
    
    [self presentLoginPage];
}



//present the oauth login page
-(void)presentLoginPage {
    
    // build the URL to the oauth page with our client_id & callback URL set.
    NSString *login = [NSString stringWithFormat:@"https://login.salesforce.com/services/oauth2/authorize?response_type=token&client_id=%@&redirect_uri=%@&display=touch",
                       [OAUTH_CLIENTID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                       [OAUTH_CALLBACK stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:login];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    [requestObj setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [[self webView] loadRequest:requestObj];
}



//intercept the webview url get request and react to the oauth confirmation
- (BOOL)webView:(UIWebView *)myWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *fullpath = [[request URL] absoluteString];
    
    if ([fullpath hasPrefix:@"ipadactivitytracker://login/success"]) {

        ZKSforceClient *client = [[[ZKSforceClient alloc] init] autorelease];
        [client loginFromOAuthCallbackUrl:fullpath oAuthConsumerKey:OAUTH_CLIENTID];
    
        NSURL *authendpoint = [client authEndpointUrl];
        
        NSLog(@"endpoint : %@", [authendpoint absoluteString]);
        
        NSString *instanceurl = [[request URL] parameterWithName:@"instance_url"];
        NSString *refreshtoken = [[request URL] parameterWithName:@"refresh_token"];
        
        [SimpleKeychain save:@"refreshtoken" data:refreshtoken];
        [SimpleKeychain save:@"instanceurl" data:instanceurl];
        
        //drop the connected client in a singleton 'SFDC', for easy access in other views
        [[SFDC sharedInstance] setClient:client];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGGEDIN" object:self];
        //[client release];
    }
        
    
    return TRUE;
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [webView release];
    [super dealloc];
}

@end
