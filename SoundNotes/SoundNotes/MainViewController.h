//
//  MainViewController.h
//  SoundNotes
//
//  Created by Rick Slot on 03/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstrumentsTableTableViewController.h"


@interface MainViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
