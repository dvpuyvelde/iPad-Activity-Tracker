//
//  LoginView.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIViewController <UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end
