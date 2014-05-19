//
//  InstrumentViewController.h
//  SoundNotes
//
//  Created by Rick Slot on 10/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundNote.h"
#import "Instruments.h"
#import <DropboxSDK/DropboxSDK.h>

@interface InstrumentViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, DBRestClientDelegate>

@property (nonatomic, strong) Instruments *instrument;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) DBRestClient *restClient;


@end
