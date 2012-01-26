//
//  OpportunitySearchController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 25/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OpportunitySearchController.h"
#import "zkSforce.h"
#import "SFDC.h"
#import "OpportunityDetailViewController.h"

@implementation OpportunitySearchController

@synthesize searchbar, selectedopportunity,opportunities;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if(!opportunities) {
        opportunities = [[NSMutableArray alloc] init];
    }
    else {
        //[opportunities removeAllObjects];
    }
}

- (void)viewDidUnload
{
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
    return [[self opportunities] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if([opportunities count] == 0) return cell;
    
    // Configure the cell...
    ZKSObject *opp = [opportunities objectAtIndex:[indexPath row]];
    cell.textLabel.text = [opp fieldValue:@"Name"];
    
    NSString *status = [[[NSString alloc] init] autorelease];
    
    if([[opp fieldValue:@"IsClosed"] isEqualToString:@"true"]) {
        status = @"Closed";
    }
    else {
        status = @"Open";
    }
    NSString *detailtext = [[[NSString alloc] initWithFormat:@"%@ - %i %@ - %@", status,(int)[[opp fieldValue:@"Amount"] floatValue], [opp fieldValue:@"CurrencyIsoCode"], [[opp fieldValue:@"Owner"] fieldValue:@"Name"]] autorelease];
    cell.detailTextLabel.text = detailtext;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    //[detailtext release];
    return cell;

}


/*
 SEARCHBAR LOGIC
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //search salesforce Opportunities
    NSString *qry = [[NSString alloc ] initWithFormat:@"FIND {%@*} IN Name Fields RETURNING Opportunity(Id, Name, Account.Name, CloseDate, IsClosed, StageName, Amount, Owner.Name, CurrencyIsoCode ORDER BY CloseDate DESC LIMIT 100)", [self searchbar].text];
    
    @try {
        ZKSforceClient *client = [[SFDC sharedInstance] client];
        NSArray *result = [client search:qry];
        [opportunities removeAllObjects];
        [opportunities addObjectsFromArray:result];
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


//when the cancel button is clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [opportunities removeAllObjects];
    [[self tableView] reloadData];
}

/* 
 hook to select opportunity from the detail view
 */
-(void)selectOpportunity:(ZKSObject*) opp {
    self.selectedopportunity = opp;
    [[self navigationController] popViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OPPORTUNITYSELECTED" object:self];
    searchbar.text = @"";
}


/*
 Accessory button tapped in a row -> show details
 */
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //get the opportunity zksobject
    ZKSObject *obj = [[self opportunities] objectAtIndex:[indexPath row]];
    OpportunityDetailViewController *detailviewcontroller = [[[OpportunityDetailViewController alloc] initWithNibName:@"OpportunityDetailViewController" bundle:nil] autorelease];
    [detailviewcontroller setOpportunity:obj];
    
    [detailviewcontroller setParentviewcontroller:self];
    [[self navigationController] pushViewController:detailviewcontroller animated:YES];
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get the opportunity zksobject
    ZKSObject *obj = [[self opportunities] objectAtIndex:[indexPath row]];
    self.selectedopportunity = obj;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OPPORTUNITYSELECTED" object:self];
}

-(void)dealloc {
    [selectedopportunity release];
    [opportunities release];
    [searchbar release];
    [super dealloc];
}

@end
