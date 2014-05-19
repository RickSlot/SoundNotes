//
//  SoundRecorder.h
//  SoundNotes
//
//  Created by Rick Slot on 10/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;

-(id) initWithFolderName: (NSString *) folderName fileName: (NSString *) fileName;
-(void) record;
-(void) play;


@end
