//
//  TypeSelectController.h
//  iPad Activity Tracker
//
//  Created by David Van Puyvelde on 21/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeSelectController : UITableViewController {
    NSMutableArray *types;
    NSString* selectedtype;
}

@property (nonatomic, retain) NSMutableArray *types;
@property (nonatomic, retain) NSString *selectedtype;

@end
