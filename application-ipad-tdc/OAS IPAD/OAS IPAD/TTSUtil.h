// Created by Sabyasachi shadangi on 05/08/2012.
// Copyright 2012 sabyasachi shadangi. All rights reserved.


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface TTSUtil : NSObject<NSURLConnectionDelegate,AVAudioPlayerDelegate> {
    NSString *isplaying;
    NSString *playerVolume;
    
}
@property (strong, nonatomic) NSMutableData *responseData;
@property BOOL playerObserver;
@property (strong, nonatomic) AVAudioPlayer *player;

- (id) init;
-(NSString *) execSpeechRequestWithText:(NSString *)text andSpeedValue:(NSString *)speedValue;
-(NSString *)stopReading;
-(NSString *)playStatus;
-(NSString *) setVolume:(NSString *)volume;
+(NSString *)decodeHtmlUnicodeCharactersToString:(NSString *) text;

@end