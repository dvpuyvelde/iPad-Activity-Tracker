//
//  SFDCEventDetailViewController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SFDCEventDetailViewController.h"
#import "FDCServerSwitchboard.h"
#import "ZKSforce.h"

@interface SFDCEventDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation SFDCEventDetailViewController
@synthesize navigationBar;
@synthesize navigationbartitle;
@synthesize RelatedToLabel;
@synthesize TypeLabel;
@synthesize SaveToSalesforceButtonOutlet;


@synthesize subjectoutlet,starttimeoutlet,endtimeoutlet,locationoutlet,relatedtooutlet,typeoutlet,descriptiontextoutlet, activity, ipadevent;
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
    [RelatedToLabel release];
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
    [self setRelatedToLabel:nil];
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
    
    [[self RelatedToLabel] setHidden:NO];
    [[self TypeLabel] setHidden:NO];    
    
    [dtf release];
}


/*
 SET THE IPAD EVENT TO DISPLAY
 */
-(void) setNewIPadEvent:(EKEvent *)newEvent {
    
    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"EEE, MMM dd - HH:mm"];
    ipadevent = newEvent;
    
    //push the values to the outlets
    self.subjectoutlet.text = [ipadevent title];
    self.starttimeoutlet.text = [dtf stringFromDate:[ipadevent startDate]];
    self.endtimeoutlet.text = [dtf stringFromDate:[ipadevent endDate]];
    //self.relatedtooutlet.text = [[activity fieldValue:@"What"] fieldValue:@"Name"];
    //self.typeoutlet.text = [activity fieldValue:@"Type"];
    self.descriptiontextoutlet.text = [ipadevent notes];
    self.locationoutlet.text = [ipadevent location];
    //self.navigationItem.title = [activity fieldValue:@"Subject"];
    self.navigationbartitle.title = [ipadevent title];
    
    [[self RelatedToLabel] setHidden:YES];
    [[self TypeLabel] setHidden:YES];
    
    [dtf release];
}


//handle the Save To Saleforce button touch
- (IBAction)saveToSalesforceClicked:(id)sender {
    
    NSMutableArray *saveobjects = [[NSMutableArray alloc] init ];
    
    //get the current selected EKEvent (will only work for iPad events)
    //TODO make it work for SFDC activities as well
    EKEvent *ev = [self ipadevent];
    
    //create the ZKSobject and set the field values
    ZKSObject *saveObj = [[ZKSObject alloc] initWithType:@"Event"];
    [saveObj setFieldValue:[ev title] field:@"Subject"];
    [saveObj setFieldValue:[ev location] field:@"Location"];
    [saveObj setFieldValue:[ev notes] field:@"Description"];
    [saveObj setFieldDateTimeValue:[ev startDate] field:@"ActivityDateTime"];
        
    //calculate meeting length
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    NSDateComponents *breakdowninfo = [sysCalendar components:NSMinuteCalendarUnit fromDate:[ev startDate] toDate:[ev endDate] options:0];
        
    NSInteger minutes = [breakdowninfo minute];
    NSString *duration = [NSString stringWithFormat:@"%d", minutes];
    [saveObj setFieldValue:duration field:@"DurationInMinutes"];
    [saveobjects addObject:saveObj];
    [saveObj release];
    
    [[FDCServerSwitchboard switchboard] create:[NSArray arrayWithObject:saveobjects] target:self selector:@selector(eventSaveResult:error:context:) context:nil];
    
    
    //NSArray *results = [client create:[NSArray arrayWithObject:saveobjects]];
    [saveobjects release];
    
}


//Handle the event Save Result
-(void)eventSaveResult:(NSArray *)results error:(NSError *)error context:(id)context {
    ZKSaveResult *sr = [results objectAtIndex:0];
    if([sr success]) {
        NSLog(@"Activity Saved");
        //notify of save. The events list listen for this to reload it's table view
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IPADEVENTSAVED" object:self];
    }
    else {
        NSLog(@"Error saving activity");
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
