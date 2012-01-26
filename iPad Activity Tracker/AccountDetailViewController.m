//
//  AccountDetailViewController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 25/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountDetailViewController.h"

@implementation AccountDetailViewController
@synthesize NameOutlet;
@synthesize OwnerOutlet;
@synthesize StreetOutlet;
@synthesize CityOutlet;
@synthesize CountryOutlet;
@synthesize account;
@synthesize parentviewcontroller;

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
    NameOutlet.text = [account fieldValue:@"Name"];
    StreetOutlet.text = [account fieldValue:@"BillingStreet"];
    CityOutlet.text = [account fieldValue:@"BillingCity"];
    CountryOutlet.text = [account fieldValue:@"BillingCountry"];
    OwnerOutlet.text = [[account fieldValue:@"Owner"] fieldValue:@"Name"];
}

- (void)viewDidUnload
{
    [self setNameOutlet:nil];
    [self setOwnerOutlet:nil];
    [self setStreetOutlet:nil];
    [self setCityOutlet:nil];
    [self setCountryOutlet:nil];
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
    [NameOutlet release];
    [OwnerOutlet release];
    [StreetOutlet release];
    [CityOutlet release];
    [CountryOutlet release];
    [super dealloc];
}


/*
 Account got selected in this detail view
 */
- (IBAction)SelectButtonClicked:(id)sender {
    
    [parentviewcontroller selectAccount:[self account]];
    
}

@end
