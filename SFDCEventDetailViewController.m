//
//  SFDCEventDetailViewController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SFDCEventDetailViewController.h"
#import "SFDC.h"
#import "ZKSforce.h"
#import "ZKPicklistEntry.h"
#import "ZKDescribeLayoutResult.h"
#import "ZKRecordTypeMapping.h"
#import "zkSaveResult.h"
#import "TypeSelectController.h"
#import "OpportunitySelectController.h"
#import "AccountSelectController.h"

@interface SFDCEventDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation SFDCEventDetailViewController
@synthesize navigationBar;
@synthesize navigationbartitle;
//@synthesize RelatedToLabel;
@synthesize TypeLabel;
@synthesize SaveToSalesforceButtonOutlet;


@synthesize subjectoutlet,starttimeoutlet,endtimeoutlet,locationoutlet,relatedtooutlet,typeoutlet,descriptiontextoutlet, activity, ipadevent;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize popoverController;
@synthesize selectedwhat, selectedwhatid, selectedtype;

- (void)configureView
{
    // Update the user interface for the detail item.
}

- (void)dealloc
{
    [selectedwhat release];
    [selectedwhatid release];    
    [_masterPopoverController release];
    [popoverController release];
    [navigationBar release];
    [navigationbartitle release];
    //[RelatedToLabel release];
    [TypeLabel release];
    [SaveToSalesforceButtonOutlet release];
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
    //[self setRelatedToLabel:nil];
    [self setTypeLabel:nil];
    [self setSaveToSalesforceButtonOutlet:nil];
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
    
    issfdcevent = YES;
    isipadevent = NO;
    
    self.navigationBar.tintColor = [UIColor blueColor];
    
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
    self.selectedtype = [activity fieldValue:@"Type"];
    self.selectedwhatid = [activity fieldValue:@"WhatId"];
    
    //[[self RelatedToLabel] setHidden:NO];
    //[[self TypeLabel] setHidden:NO];    
    
    [dtf release];
}


/*
 SET THE IPAD EVENT TO DISPLAY
 */
-(void) setNewIPadEvent:(EKEvent *)newEvent {
    
    isipadevent = YES;
    issfdcevent = NO;
    
    self.navigationBar.tintColor = [UIColor redColor];
    
    self.relatedtooutlet.text = @"";
    self.typeoutlet.text = @"";
    self.selectedwhatid = nil;
    self.selectedtype = nil;
    
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"EEE, MMM dd - HH:mm"];
    self.ipadevent = newEvent;
    
    //push the values to the outlets
    self.subjectoutlet.text = [ipadevent title];
    self.starttimeoutlet.text = [dtf stringFromDate:[ipadevent startDate]];
    self.endtimeoutlet.text = [dtf stringFromDate:[ipadevent endDate]];
    //self.relatedtooutlet.text = [[activity fieldValue:@"What"] fieldValue:@"Name"];
    //self.typeoutlet.text = [activity fieldValue:@"Type"];
    self.descriptiontextoutlet.text = [ipadevent notes];
    self.locationoutlet.text = [ipadevent location];
    self.navigationbartitle.title = [ipadevent title];

    
    [dtf release];
}


/*
SAVE TO SALESFORCE
 */
- (IBAction)saveToSalesforceClicked:(id)sender {
    
    
    //don't save as long as no event has been selected
    if(!isipadevent && !issfdcevent) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: @"Please select an item first"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    
    NSMutableArray *saveobjects = [[NSMutableArray alloc] init ];
    ZKSObject *saveObj;
    
    //get the current selected EKEvent (will only work for iPad events)
    //TODO make it work for SFDC activities as well
    if(isipadevent) {
        EKEvent *ev = [self ipadevent];
    
        //create the ZKSobject and set the field values
        saveObj = [[ZKSObject alloc] initWithType:@"Event"];
        [saveObj setFieldValue:[ev title] field:@"Subject"];
        [saveObj setFieldValue:[ev location] field:@"Location"];
        [saveObj setFieldValue:[ev notes] field:@"Description"];
        [saveObj setFieldDateTimeValue:[ev startDate] field:@"ActivityDateTime"];
        [saveObj setFieldValue:[self selectedwhatid] field:@"WhatId"];
        [saveObj setFieldValue:[self selectedtype] field:@"Type"];
        
        //calculate meeting length
        // Get the system calendar
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
        NSDateComponents *breakdowninfo = [sysCalendar components:NSMinuteCalendarUnit fromDate:[ev startDate] toDate:[ev endDate] options:0];
        
        NSInteger minutes = [breakdowninfo minute];
        NSString *duration = [NSString stringWithFormat:@"%d", minutes];
        [saveObj setFieldValue:duration field:@"DurationInMinutes"];
        [saveobjects addObject:saveObj];
    }
    if(issfdcevent) {
        saveObj = saveObj = [[ZKSObject alloc] initWithType:@"Event"];
        [saveObj setFieldValue:[[self activity] fieldValue:@"Id"] field:@"Id"];
        [saveObj setFieldValue:[self selectedwhatid] field:@"WhatId"];
        [saveObj setFieldValue:[self selectedtype] field:@"Type"];

        [saveobjects addObject:saveObj];
    }
    
    NSArray *results;
    
    @try {
        if(isipadevent) { results = [[[SFDC sharedInstance] client] create:[NSArray arrayWithObject:saveobjects]]; }
        if(issfdcevent) { results = [[[SFDC sharedInstance] client] update:[NSArray arrayWithObject:saveobjects]]; }
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: [exception description]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

    
    
    ZKSaveResult *sr = [results objectAtIndex:0];
    if([sr success]) {
        NSLog(@"Activity Saved");
        //notify of save. The events list listen for this to reload it's table view
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IPADEVENTSAVED" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SFDCEVENTSAVED" object:self];
    }
    else {
        NSLog(@"Error saving activity");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: [sr message]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
    //NSArray *results = [client create:[NSArray arrayWithObject:saveobjects]];
    [saveobjects release];
    [saveObj release];
}


/*
    POPUP ACTIVITY TYPE SELECT
 */
- (IBAction)TypeButtonTouched:(id)sender {
    TypeSelectController *typeselect = [[TypeSelectController alloc] initWithNibName:@"TypeSelectController" bundle:[NSBundle mainBundle]];
    typeselect.title = @"Activity Types";
    
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:typeselect];
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
    self.selectedtype = [tsc selectedtype];
    [[self popoverController] dismissPopoverAnimated:NO];
}


/*
    POPUP RELATEDTO SELECT
 */
- (IBAction)RelatedToButtonTouched:(id)sender {
    //create the opportunity select controller for following opportunities
    OpportunitySelectController *oppcon1 = [[OpportunitySelectController alloc] initWithNibName:@"OpportunitySelectController" bundle:[NSBundle mainBundle]];
    oppcon1.tabBarItem.image = [UIImage imageNamed:@"piggy.png"];
    //oppcon1.opportunities = (NSMutableArray *)[self myopportunities];
    //oppcon1.allopportunities = [[self myopportunities] copy];
    oppcon1.title = @"Opportunities";
    oppcon1.opportunities = [NSMutableArray arrayWithArray:[[[SFDC sharedInstance] getDefaultUserOpportunities] copy]];
    oppcon1.allopportunities = [NSMutableArray arrayWithArray:[[oppcon1 opportunities] copy]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(opportunityselected:) name:@"OPPORTUNITYSELECTED" object:oppcon1];

    AccountSelectController *accountcon = [[AccountSelectController alloc] initWithNibName:@"AccountSelectController" bundle:[NSBundle mainBundle]];
    accountcon.title = @"Accounts";
    accountcon.tabBarItem.image = [UIImage imageNamed:@"bank.png"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountselected:) name:@"ACCOUNTSELECTED" object:accountcon];
    
    //create the tabbarcontroller
    UITabBarController *tabCon = [[UITabBarController alloc] init];
    
    tabCon.viewControllers = [[NSArray alloc] initWithObjects:oppcon1, accountcon, nil];
    
    
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:tabCon];
    
    
    
    UIButton *button = sender;
    
    if ([self.popoverController isPopoverVisible]) {
        
        [self.popoverController dismissPopoverAnimated:YES];
        
    } else {
        
        [self.popoverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    
    [tabCon release];
    [oppcon1 release];
    [accountcon release];
}

//when an account is selected
-(void)accountselected:(NSNotification*)notification {
    AccountSelectController *asc = [notification object];
    ZKSObject *acc = [asc selectedaccount];
    
    
    self.selectedwhat = [acc fieldValue:@"What"];
    self.selectedwhatid = [acc fieldValue:@"Id"];
    
    self.relatedtooutlet.text = [acc fieldValue:@"Name"];
    
    [[self popoverController] dismissPopoverAnimated:NO];
}

//when an opportunity is selected
-(void)opportunityselected:(NSNotification*)notification {
    OpportunitySelectController *osc = [notification object];
    ZKSObject *opp = [osc selectedopportunity];
    
    self.relatedtooutlet.text = [opp fieldValue:@"Name"];
    
    self.selectedwhatid = [opp fieldValue:@"Id"];
    self.selectedwhat = [opp fieldValue:@"What"];
    
    [[self popoverController] dismissPopoverAnimated:NO];
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

- (IBAction)logoutButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:self];
}


@end
