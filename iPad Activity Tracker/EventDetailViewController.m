//
//  SFDCEventDetailViewController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 05/12/11.
//  Copyright (c) 2012 Salesforce.com. All rights reserved.
//

#import "EventDetailViewController.h"
#import "SFDC.h"
#import "ZKSforce.h"
#import "ZKPicklistEntry.h"
#import "ZKDescribeLayoutResult.h"
#import "ZKRecordTypeMapping.h"
#import "zkSaveResult.h"
#import "TypeSelectController.h"
#import "OpportunitySelectController.h"
#import "OpportunitySearchController.h"
#import "OpportunityDetailViewController.h"
#import "AccountSelectController.h"

@interface EventDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation EventDetailViewController
@synthesize activityIndicator;
@synthesize DeleteFromSalesforceButtonOutlet;
@synthesize ImageCalendarTypeOutlet;
@synthesize WebView;
@synthesize navigationBar;
@synthesize navigationbartitle;
@synthesize TypeLabel;
@synthesize SaveToSalesforceButtonOutlet;


@synthesize subjectoutlet,starttimeoutlet,endtimeoutlet,locationoutlet,relatedtooutlet,typeoutlet,descriptiontextoutlet;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize popoverController;
@synthesize atevent;

- (void)configureView
{
    // Update the user interface for the detail item.
}

- (void)dealloc
{ 
    [_masterPopoverController release];
    [popoverController release];
    [navigationBar release];
    [navigationbartitle release];
    [store release];
    [TypeLabel release];
    [SaveToSalesforceButtonOutlet release];
    [DeleteFromSalesforceButtonOutlet release];
    [ImageCalendarTypeOutlet release];
    [WebView release];
    [activityIndicator release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        store = [[EKEventStore alloc] init];
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
    [self showHelp];
}

- (void)viewDidUnload
{
    [self setNavigationBar:nil];
    [self setNavigationbartitle:nil];
    [self setTypeLabel:nil];
    [self setSaveToSalesforceButtonOutlet:nil];
    [self setDeleteFromSalesforceButtonOutlet:nil];
    [self setImageCalendarTypeOutlet:nil];
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}



/*
 SET THE ATEVENT TO DISPLAY
 */
-(void) setNewEvent:(ATEvent *)newEvent {
    
    if(newEvent == nil) {
        [self showHelp];
        return;
    }
    
    [self hideHelp];
    
    self.relatedtooutlet.text = [newEvent what];
    self.typeoutlet.text = [newEvent type];
    
    
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"EEE, MMM dd - HH:mm"];
    self.atevent = newEvent;
    
    //push the values to the outlets
    self.subjectoutlet.text = [newEvent subject];
    self.starttimeoutlet.text = [dtf stringFromDate:[atevent startdate]];
    self.typeoutlet.text = [atevent type];
    self.endtimeoutlet.text = [dtf stringFromDate:[atevent enddate]];
    self.descriptiontextoutlet.text = [atevent description];
    self.locationoutlet.text = [atevent location];
    self.navigationbartitle.title = [atevent subject];
    
    //adapt the UI a bit, depending on which type of event we're looking at (SFDC or iPad)
    if(self.atevent.isSFDCEvent) {
        [SaveToSalesforceButtonOutlet setTitle:@"Update in Salesforce" forState:UIControlStateNormal];
        [DeleteFromSalesforceButtonOutlet setTitle:@"Delete from Salesforce"];
        UIImage *sfdcicon = [UIImage imageNamed:@"SFDCLogo2-small.jpg"];
        [ImageCalendarTypeOutlet setImage:sfdcicon];
    }
    if(self.atevent.isIpadEvent) {
        [SaveToSalesforceButtonOutlet setTitle:@"Save to Salesforce" forState:UIControlStateNormal];
        [DeleteFromSalesforceButtonOutlet setTitle:@"Delete from iPad"];
        UIImage *ipadcalendaricon = [UIImage imageNamed:@"Calendar.png"];
        [ImageCalendarTypeOutlet setImage:ipadcalendaricon];
    }
    [dtf release];
}



/*
SAVE TO SALESFORCE
 */
- (IBAction)saveToSalesforceClicked:(id)sender {
    
    
    //don't save as long as no event has been selected
    if(!atevent) {
        [self alert:@"Please select an item first"];
    }
    
    
    NSMutableArray *saveobjects = [[NSMutableArray alloc] init ];
    ZKSObject *saveObj;

    
    //get the current selected ATEvent
    if([atevent isIpadEvent]) {
        ATEvent *ev = [self atevent];
    
        //create the ZKSobject and set the field values
        saveObj = [[[ZKSObject alloc] initWithType:@"Event"] autorelease];
        [saveObj setFieldValue:[ev subject] field:@"Subject"];
        [saveObj setFieldValue:[ev location] field:@"Location"];
        [saveObj setFieldValue:[ev description] field:@"Description"];
        [saveObj setFieldDateTimeValue:[ev startdate] field:@"ActivityDateTime"];
        [saveObj setFieldValue:[ev whatid] field:@"WhatId"];
        [saveObj setFieldValue:[ev type] field:@"Type"];
        
        //calculate meeting length
        // Get the system calendar
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
        NSDateComponents *breakdowninfo = [sysCalendar components:NSMinuteCalendarUnit fromDate:[ev startdate] toDate:[ev enddate] options:0];
        
        NSInteger minutes = [breakdowninfo minute];
        NSString *duration = [NSString stringWithFormat:@"%d", minutes];
        [saveObj setFieldValue:duration field:@"DurationInMinutes"];
        [saveobjects addObject:saveObj];
    }
    else if([atevent isSFDCEvent]) {
        saveObj = [[[ZKSObject alloc] initWithType:@"Event"] autorelease];
        [saveObj setFieldValue:[atevent sfdcid] field:@"Id"];
        [saveObj setFieldValue:[atevent whatid] field:@"WhatId"];
        [saveObj setFieldValue:[atevent type] field:@"Type"];

        [saveobjects addObject:saveObj];
    }
    

    [activityIndicator startAnimating];
    [activityIndicator setHidden:NO];
    
    //save in the background
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        NSArray *results;
        @try {
            if([atevent isIpadEvent]) { results = [[[SFDC sharedInstance] client] create:[NSArray arrayWithObject:saveobjects]]; }
            if([atevent isSFDCEvent]) { results = [[[SFDC sharedInstance] client] update:[NSArray arrayWithObject:saveobjects]]; }
        }
        @catch (NSException *exception) {
            [activityIndicator stopAnimating];
            [activityIndicator setHidden:YES];
            [self alert:[exception description]];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            ZKSaveResult *sr = [results objectAtIndex:0];
            if([sr success]) {
                //always set the id when a successfull save is done (this will turn an iPad event in a SFDC event
                [atevent setSfdcid:[sr id]];
                [self setNewEvent:atevent];
                //notify of save. The events list listen for this to reload it's table view
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EVENTSAVED" object:self];
            }
            else {
                [self alert:[sr message]];        
            }
            
            
            
            [activityIndicator stopAnimating];
            [activityIndicator setHidden:YES];
        });
    });
    [saveobjects release];
    //[saveObj release];
    
}




/*
    POPUP ACTIVITY TYPE SELECT
 */
- (IBAction)TypeButtonTouched:(id)sender {
    TypeSelectController *typeselect = [[TypeSelectController alloc] initWithNibName:@"TypeSelectController" bundle:[NSBundle mainBundle]];
    typeselect.title = @"Activity Types";
    
    self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:typeselect] autorelease];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(typeselected:) name:@"TYPESELECTED" object:typeselect];
    
    UIButton *button = sender;
    
    if ([self.popoverController isPopoverVisible]) {
        
        [self.popoverController dismissPopoverAnimated:YES];
        
    } else {
        
        [self.popoverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    
    [typeselect release];
}



//when type selected notification comes back
-(void)typeselected:(NSNotification*)notification {
    TypeSelectController *tsc = [notification object];
    self.typeoutlet.text = [tsc selectedtype];
    self.atevent.type = [tsc selectedtype];
    [[self popoverController] dismissPopoverAnimated:NO];
    //autosave
    [self saveToSalesforceClicked:nil];
}




/*
    POPUP RELATEDTO SELECT
 */
- (IBAction)RelatedToButtonTouched:(id)sender {
    //create the opportunity select controller for following opportunities
    OpportunitySelectController *oppcon1 = [[[OpportunitySelectController alloc] initWithNibName:@"OpportunitySelectController" bundle:[NSBundle mainBundle]] autorelease];
    oppcon1.tabBarItem.image = [UIImage imageNamed:@"piggy.png"];
    oppcon1.title = @"My Opportunities";
    oppcon1.opportunities = [NSMutableArray arrayWithArray:[[[SFDC sharedInstance] getDefaultUserOpportunities] copy]];
    oppcon1.allopportunities = [NSMutableArray arrayWithArray:[[oppcon1 opportunities] copy]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(opportunityselected:) name:@"OPPORTUNITYSELECTED" object:oppcon1];

    //create the opportunity search controller
    OpportunitySearchController *oppsearchcon = [[[OpportunitySearchController alloc] initWithNibName:@"OpportunitySearchController" bundle:nil] autorelease];
    oppsearchcon.title = @"Search Opportunities";
    oppsearchcon.tabBarItem.image = [UIImage imageNamed:@"magnifyingglass.png"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(opportunityselected:) name:@"OPPORTUNITYSELECTED" object:oppsearchcon];
    
    //create the account select (search) controller
    AccountSelectController *accountcon = [[[AccountSelectController alloc] initWithNibName:@"AccountSelectController" bundle:[NSBundle mainBundle]] autorelease];
    accountcon.title = @"Search Accounts";
    accountcon.tabBarItem.image = [UIImage imageNamed:@"bank.png"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountselected:) name:@"ACCOUNTSELECTED" object:accountcon];
    
    //create the tabbarcontroller
    UITabBarController *tabCon = [[UITabBarController alloc] init];
    
    //create a navigation controller to drop the my opportunity list in
    UINavigationController *oppnavcon = [[[UINavigationController alloc] initWithRootViewController:oppcon1] autorelease];
    //create a navigation controller to drop the search opportunities view in
    UINavigationController *oppsearchnavcon = [[[UINavigationController alloc] initWithRootViewController:oppsearchcon] autorelease];
    //create a navigation controller to drop the search account view in
    UINavigationController *accountssearchnavcon = [[UINavigationController alloc] initWithRootViewController:accountcon];
    
    tabCon.viewControllers = [[NSArray alloc] initWithObjects:oppnavcon, oppsearchnavcon, accountssearchnavcon, nil];
    
    
    self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:tabCon] autorelease];
    
    
    
    UIButton *button = sender;
    
    if ([self.popoverController isPopoverVisible]) {
        
        [self.popoverController dismissPopoverAnimated:YES];
        
    } else {
        
        [self.popoverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    
    [tabCon release];
}




/*
 DELETE Button Clicked
 */
- (IBAction)deleteButtonClicked:(id)sender {
    //delete event from the iPad calendar
    if([atevent isIpadEvent]) {
        @try {
            EKEvent *event = [store eventWithIdentifier:[atevent ekeventid]];
            if(event != nil) {
                NSError *error = nil;
                [store removeEvent:event span:EKSpanThisEvent error:&error];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SFDCEVENTDELETED" object:self];
                [self setNewEvent:nil];
            }
        }
        @catch (NSException *exception) {
            [self alert:[exception description]];
        }
    }
    //delete event from Salesforce
    if([atevent isSFDCEvent]) {
        @try {
            NSString *objid = [atevent sfdcid];
            NSArray* objarray = [[[NSArray alloc] initWithObjects:objid, nil] autorelease];
            [[[SFDC sharedInstance] client] delete:objarray];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SFDCEVENTDELETED" object:self];
            self.atevent.sfdcid = nil;
            self.atevent.what = nil;
            self.atevent.whatid = nil;
            self.atevent.type = nil;
            [self setNewEvent:atevent];
        }
        @catch (NSException *exception) {
            [self alert:[exception description]];
        }
    }
}



/*
 when an ACCOUNT is selected
 */
-(void)accountselected:(NSNotification*)notification {
    AccountSelectController *asc = [notification object];
    ZKSObject *acc = [asc selectedaccount];
    
    
    self.atevent.what = [acc fieldValue:@"Name"];
    self.atevent.whatid = [acc fieldValue:@"Id"];
    
    self.relatedtooutlet.text = [acc fieldValue:@"Name"];
    
    [[self popoverController] dismissPopoverAnimated:NO];
    
    //autosave
    [self saveToSalesforceClicked:nil];
}



/*
 when an OPPORTUNITY is selected
 */
-(void)opportunityselected:(NSNotification*)notification {
    //these notifications can come from the list view, search view
    NSObject *source = [notification object];
    ZKSObject *opp;
    if([source isKindOfClass:[OpportunitySelectController class]]) {
        OpportunitySelectController *osc = [notification object];
        opp = [osc selectedopportunity];
    }
    if([source isKindOfClass:[OpportunitySearchController class]]) {
        OpportunitySearchController *osc = [notification object];
        opp = [osc selectedopportunity];
    }

    self.relatedtooutlet.text = [opp fieldValue:@"Name"];
    
    self.atevent.whatid = [opp fieldValue:@"Id"];
    self.atevent.what = [opp fieldValue:@"Name"];
    
    [[self popoverController] dismissPopoverAnimated:NO];
    
    //autosave
    [self saveToSalesforceClicked:nil];
}





#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = [self popoverController];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

/*
 When the HELP button is clicked
 */
- (IBAction)HomeButtonClicked:(id)sender {
    [self showHelp];
}

/*
 Show the HELP UIWebView
 */
-(void)showHelp {
    [WebView setHidden:NO];
    [[self navigationbartitle] setTitle:@""];
    [WebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]isDirectory:NO]]];
}

/*
 Hide the Help view
 */
-(void)hideHelp {
    [WebView setHidden:YES];
}

/*
 When the LOGOUT button is clicked
 */
- (IBAction)logoutButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:self];
}

/* 
 ALERT 
*/
-(void)alert:(NSString*) message {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Error"
                          message: message
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert release];
}


@end
