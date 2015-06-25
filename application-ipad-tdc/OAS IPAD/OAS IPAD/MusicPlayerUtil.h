//
//  MusicPlayerUtil.h
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 10/29/12.
//  Copyright (c) 2012 mcgrawhill ctb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MusicPlayerUtil : NSObject <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *player;
@property NSString *musicFile;


-(id)initWithFileName:(NSString *)fileName;


-(NSString *) startPlaying;
-(NSString *) stopPlaying;
-(NSString *) setVolume:(NSString *)volume;



@end
