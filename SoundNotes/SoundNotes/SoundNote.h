//
//  SoundNote.h
//  SoundNotes
//
//  Created by Rick Slot on 03/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Instruments;

@interface SoundNote : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *instruments;
@end

@interface SoundNote (CoreDataGeneratedAccessors)

- (void)addInstrumentsObject:(Instruments *)value;
- (void)removeInstrumentsObject:(Instruments *)value;
- (void)addInstruments:(NSSet *)values;
- (void)removeInstruments:(NSSet *)values;

@end
