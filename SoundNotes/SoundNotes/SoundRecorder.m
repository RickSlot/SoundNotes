//
//  SoundRecorder.m
//  SoundNotes
//
//  Created by Rick Slot on 10/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import "SoundRecorder.h"

@implementation SoundRecorder

NSURL *outputFileUrl = nil;

/**
 * This function returns a new soundrecorder instance with the destination folder set to the given folder name
 */
-(id) initWithFolderName: (NSString *) folderName fileName: (NSString *) fileName{
    if( self=[super init] )
    {
        
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [[NSString alloc] initWithFormat:@"/%@/%@.m4a", folderName, fileName],
                                   nil];
        outputFileUrl = [NSURL fileURLWithPathComponents:pathComponents];
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"/%@", folderName]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileUrl settings:recordSetting error:NULL];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
    }
    return self;
}

/**
 * This function starts recording when it is not recording. if it is recording it stops recording
 */
-(void) record{
    if (!_recorder.recording) {
        [_recorder prepareToRecord];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        NSLog(@"start recording");
        [_recorder record];
        
    } else {
        NSLog(@"stop recording");
        [_recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
    }
}

/**
 * This function plays the sound that has been recorded
 */
-(void) play{
    if (!_recorder.recording){
        NSLog(@"play sound:");

        NSError *error = nil;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:outputFileUrl fileTypeHint:@"m4a" error:&error];
        [_player setDelegate:self];
        [_player prepareToPlay];
        if(![_player play]){
            NSLog(@"error in playing, %@", error);
        }
    }
}



@end
