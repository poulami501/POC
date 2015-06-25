//
//  AudioRecorderUtils.h
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 10/28/12.
//  Copyright (c) 2012  mcgrawhill ctb . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecorderUtils : NSObject <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
@property (strong, nonatomic) AVAudioRecorder *recorder;
//@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSString *soundFilePath;



-(id)initWithFileName:(NSString *)fileName;


-(NSString *) startRecording;
-(NSString *) stopRecording;
-(NSString *) reset;

@end
