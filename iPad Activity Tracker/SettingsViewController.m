//
//  SettingsViewController.m
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 26/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Cell 0-0
    if([indexPath row] == 0) {
        cell.textLabel.text = @"Show iPad calendar";
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        //check if the users wants to include ipad events as well in the list
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *needtoshowipadevents = [defaults objectForKey:@"ATShowIPadEvents"];
        
        if(needtoshowipadevents == nil || [needtoshowipadevents isEqualToString:@"YES"]) {
            [switchView setOn:YES animated:NO];
        }
        else {
            [switchView setOn:NO animated:NO];
        }
        
        [switchView addTarget:self action:@selector(showipadsettingschanged:) forControlEvents:UIControlEventValueChanged];
        [switchView release];
    }
    return cell;
}


/*
    Show iPad calendar items
 */
- (void) showipadsettingschanged:(id)sender {
    UISwitch* switchControl = sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value;
    if(switchControl.on) {
        value = @"YES";
    }
    else {
        value = @"NO";
    }
    //store this in the user defaults
    [defaults setObject:value forKey:@"ATShowIPadEvents"];
    
    [defaults synchronize];
    //let the list view know
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOWSETTINGSCHANGED" object:self];
}


/*
 TABLE SECTION HEADERS
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Settings";
    }
    return @"";
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
