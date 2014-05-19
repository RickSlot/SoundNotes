//
//  AppDelegate.h
//  SoundNotes
//
//  Created by Rick Slot on 01/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <DropboxSDK/DropboxSDK.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, DBSessionDelegate, DBNetworkRequestDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
