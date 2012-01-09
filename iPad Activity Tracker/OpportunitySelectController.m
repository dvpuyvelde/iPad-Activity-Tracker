//
//  OpportunitySelectController.m
//  Activity Tracker
//
//  Created by David Van Puyvelde on 20/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpportunitySelectController.h"
#import "ZKSObject.h"
#import "SFDC.h"


@implementation OpportunitySelectController

@synthesize searchbar;
@synthesize opportunities;
@synthesize allopportunities;
@synthesize selectedopportunity;

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
    [selectedopportunity release];
    [allopportunities release];
    [opportunities release];
    [searchbar release];
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
    
    //allopportunities = [[SFDC sharedInstance] getDefaultUserOpportunities];
    //opportunities = [NSMutableArray arrayWithArray:[allopportunities copy]];
}

- (void)viewDidUnload
{
    [self setSearchbar:nil];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"My Opportunities";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    ZKSObject *obj = [[self opportunities] objectAtIndex:[indexPath row]];
    cell.textLabel.text = [obj fieldValue:@"Name"];
    NSString *detailtext = [[NSString alloc] initWithFormat:@"%i %@ - %@",(int)[[obj fieldValue:@"Amount"] floatValue], [obj fieldValue:@"CurrencyIsoCode"], [[obj fieldValue:@"Owner"] fieldValue:@"Name"]];
    cell.detailTextLabel.text = detailtext;
    
    [detailtext release];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //get the opportunity zksobject
    ZKSObject *obj = [[self opportunities] objectAtIndex:[indexPath row]];
    self.selectedopportunity = obj;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OPPORTUNITYSELECTED" object:self];
    
    //when an opp got selected, reset all the search stuff
    //[[self opportunities] removeAllObjects];
    //[[self opportunities] addObjectsFromArray:[self allopportunities]];
    searchbar.text = @"";
    
}

/*
            Opportunity searchbar logic
 */

//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:YES animated:YES];
    //self.tableView.allowsSelection = NO;
    //self.tableView.scrollEnabled = NO;
    //self.theTableView.allowsSelection = NO;
    //self.theTableView.scrollEnabled = NO;
//}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    //clear the opportunities
    [[self opportunities] removeAllObjects];
    
    if([searchText length] == 0) {
        [[self opportunities] addObjectsFromArray:[self allopportunities]];
        [[self tableView] reloadData];
        return;
    }
    
    //loop over all opportunities and add only those that match
    for(ZKSObject *opp in self.allopportunities) {
        NSString *name = [opp fieldValue:@"Name"];
        NSRange range = [name rangeOfString :searchText options:NSCaseInsensitiveSearch];
        if(range.location != NSNotFound) {
            [self.opportunities addObject:opp];
            continue;
        }
        //if it hasn't been found above, try the opp owner name as well
        NSString *ownername = [[opp fieldValue:@"Owner"] fieldValue:@"Name"];
        NSRange range2 = [ownername rangeOfString :searchText options:NSCaseInsensitiveSearch];
        if(range2.location != NSNotFound) {
            [self.opportunities addObject:opp];
        }
    }
    [[self tableView] reloadData];
}
/*
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.theTableView.allowsSelection = YES;
    self.theTableView.scrollEnabled = YES;
}*/

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    self.searchbar.text = @"";
//    [self.searchbar setShowsCancelButton:NO animated:YES];
    //self.tableView.allowsSelection = YES;
    //self.tableView.scrollEnabled = YES;
//    [opportunities removeAllObjects];
//    [opportunities addObjectsFromArray:allopportunities];
    
//}

@end
