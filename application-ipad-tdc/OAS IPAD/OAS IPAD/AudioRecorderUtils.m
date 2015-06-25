//
//  AudioRecorderUtils.m
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 10/28/12.
//  Copyright (c) 2012 mcgrawhill ctb. All rights reserved.
//

#import "AudioRecorderUtils.h"

@implementation AudioRecorderUtils

@synthesize recorder;
//@synthesize player;
@synthesize soundFilePath;

//Method to initiate the Recorder

-(id)initWithFileName:(NSString *)fileName
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    
    //Look for Documents Directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    //Make the file name and path
    fileName= [fileName stringByAppendingString:@".aac"];
    soundFilePath = [docsDir
                               stringByAppendingPathComponent:fileName];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    
    //Recorder settings
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMax],
                                    AVEncoderAudioQualityKey,[NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:16000.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    //Initiate recorder
    recorder = [[AVAudioRecorder alloc]
                initWithURL:soundFileURL
                settings:recordSettings
                error:&error];
    
    if (error)
    {
        //NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [recorder prepareToRecord];
    }
    
    return [super init];
    
}

//Method to start recording with given settings
//Make sure initWithFileName is  called before any other method is called
-(NSString *) startRecording
{
    [recorder record];
    //return @"<result>RECORDING_START</result>";
    return @"RECORDING_START";
}



//Method to start recording with given settings
-(NSString *) stopRecording
{
    [recorder stop];
    return @"RECORDING_STOP";
}


//Function to reset the recording and 
-(NSString *) reset
{
    [[NSFileManager defaultManager] removeItemAtPath:soundFilePath error:nil];
    
    return @"AUDIO_DELETED";
}



@end
