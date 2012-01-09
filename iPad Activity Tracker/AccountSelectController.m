//
//  AccountSelectController.m
//  Activity Tracker
//
//  Created by David Van Puyvelde on 28/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountSelectController.h"
#import "ZKSforce.h"
#import "SFDC.h"


@implementation AccountSelectController
@synthesize searchBar;
@synthesize accounts;
@synthesize selectedaccount;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [selectedaccount release];
    [accounts release];
    [searchBar release];
    [super dealloc];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if(!accounts) {
        accounts = [[NSMutableArray alloc] init];
    }
}

- (void)viewDidUnload
{
    selectedaccount = nil;
    accounts = nil;
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    ZKSObject *acc = [accounts objectAtIndex:[indexPath row]];
    cell.textLabel.text = [acc fieldValue:@"Name"];
    NSString *detailtext = [[NSString alloc ] initWithFormat:@"%@, %@ - %@ / @%", [acc fieldValue:@"BillingStreet"], [acc fieldValue:@"BillingCity"], [acc fieldValue:@"BillingCountry"], [[acc fieldValue:@"Owner"] fieldValue:@"Name"]];
    cell.detailTextLabel.text = detailtext;
    
    [detailtext release];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedaccount = [[self accounts] objectAtIndex:[indexPath row]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ACCOUNTSELECTED" object:self];
}

/*
    SEARCHBAR LOGIC
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //search salesforce Accounts
    NSString *qry = [[NSString alloc ] initWithFormat:@"FIND {%@*} IN Name Fields RETURNING Account(Id, Name, BillingCountry, BillingCity, BillingStreet, Owner.Name LIMIT 100)", [self searchBar].text];
    
    @try {
        ZKSforceClient *client = [[SFDC sharedInstance] client];
        NSArray *result = [client search:qry];
        [accounts removeAllObjects];
        [accounts addObjectsFromArray:result];
        [[self tableView] reloadData];
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
    [qry release];
}

//when the user enters the search input
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [accounts removeAllObjects];
}

//when the cancel button is clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [accounts removeAllObjects];
}

@end
