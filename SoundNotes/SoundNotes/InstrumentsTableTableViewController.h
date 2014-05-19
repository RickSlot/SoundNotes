//
//  InstrumentsTableTableViewController.h
//  SoundNotes
//
//  Created by Rick Slot on 04/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundNote.h"
#import "Instruments.h"
#import "InstrumentViewController.h"

@interface InstrumentsTableTableViewController : UITableViewController

@property (nonatomic, strong) SoundNote *soundNote;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
