//
//  OpportunityDetailViewController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OpportunityDetailViewController.h"
#import "OpportunitySelectController.h"
#import "Utils.h"

@implementation OpportunityDetailViewController

@synthesize opportunity;
@synthesize parentviewcontroller;
@synthesize NameOutlet;
@synthesize OwnerOutlet;
@synthesize CloseDateOutlet;
@synthesize AmountOutlet;
@synthesize AccountOutlet;
@synthesize StageOutlet;

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
    NameOutlet.text = [self.opportunity fieldValue:@"Name"];
    OwnerOutlet.text = [[self.opportunity fieldValue:@"Owner"] fieldValue:@"Name"];
    AccountOutlet.text = [[self.opportunity fieldValue:@"Account"] fieldValue:@"Name"];
    StageOutlet.text = [self.opportunity fieldValue:@"StageName"];
    
    //try to get the close date in user's locale
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    CloseDateOutlet.text = [dateFormatter stringFromDate:[self.opportunity dateValue:@"CloseDate"]];
    //get the Amount (float) without the .0 at then end
    AmountOutlet.text = [[[NSString alloc] initWithFormat:@"%i %@", (int)[[self.opportunity fieldValue:@"Amount"] floatValue], [self.opportunity fieldValue:@"CurrencyIsoCode"]] autorelease];
}

- (void)viewDidUnload
{
    [self setNameOutlet:nil];
    [self setOwnerOutlet:nil];
    [self setCloseDateOutlet:nil];
    [self setAmountOutlet:nil];
    [self setAccountOutlet:nil];
    [self setStageOutlet:nil];
    [self setOpportunity:nil];
    //[self parentviewcontroller:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*
 Opportunity got selected in this detail view
 */
- (IBAction)SelectButtonClicked:(id)sender {
    
    [parentviewcontroller selectOpportunity:[self opportunity]];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [NameOutlet release];
    [OwnerOutlet release];
    [CloseDateOutlet release];
    [AmountOutlet release];
    [AccountOutlet release];
    [StageOutlet release];
    [super dealloc];
}
@end
