//
//  SFDCEventDetailViewController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SFDCEventDetailViewController.h"

@interface SFDCEventDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation SFDCEventDetailViewController
@synthesize navigationBar;
@synthesize navigationbartitle;


@synthesize subjectoutlet,starttimeoutlet,endtimeoutlet,locationoutlet,relatedtooutlet,typeoutlet,descriptiontextoutlet, activity;
@synthesize masterPopoverController = _masterPopoverController;


- (void)configureView
{
    // Update the user interface for the detail item.
}

- (void)dealloc
{
    [_masterPopoverController release];
    [navigationBar release];
    [navigationbartitle release];
    [super dealloc];
}

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setNavigationBar:nil];
    [self setNavigationbartitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


/*
 SET THE SALESFORCE EVENT TO DISPLAY
 */
-(void) setActivity:(ZKSObject *)newActivity {
    
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"EEE, MMM dd - HH:mm"];
    activity = newActivity;
    
    //push the values to the outlets
    self.subjectoutlet.text = [activity fieldValue:@"Subject"];
    self.starttimeoutlet.text = [dtf stringFromDate:[activity dateTimeValue:@"StartDateTime"]];
    self.endtimeoutlet.text = [dtf stringFromDate:[activity dateTimeValue:@"EndDateTime"]];
    self.relatedtooutlet.text = [[activity fieldValue:@"What"] fieldValue:@"Name"];
    self.typeoutlet.text = [activity fieldValue:@"Type"];
    self.descriptiontextoutlet.text = [activity fieldValue:@"Description"];
    self.locationoutlet.text = [activity fieldValue:@"Location"];
    //self.navigationItem.title = [activity fieldValue:@"Subject"];
    self.navigationbartitle.title = [activity fieldValue:@"Subject"];
    [dtf release];
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (IBAction)logoutButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:self];
}


@end
