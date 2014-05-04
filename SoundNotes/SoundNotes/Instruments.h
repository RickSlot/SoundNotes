//
//  Instruments.h
//  SoundNotes
//
//  Created by Rick Slot on 03/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Instruments : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * lyrics;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * soundFile;
@property (nonatomic, retain) NSManagedObject *soundNote;

@end
