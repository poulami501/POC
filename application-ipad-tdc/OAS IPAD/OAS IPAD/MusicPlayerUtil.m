//
//  MusicPlayerUtil.m
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 10/29/12.
//  Copyright (c) 2012 mcgrawhill ctb. All rights reserved.
//

#import "MusicPlayerUtil.h"

@implementation MusicPlayerUtil

@synthesize player;
@synthesize musicFile;

-(id)initWithFileName:(NSString *)fileName{
    musicFile=fileName;
    NSData* soundData = [NSData dataWithContentsOfFile:musicFile];
    player=[[AVAudioPlayer alloc] initWithData:soundData error:nil];
   // NSLog(@"Music player initiated with file: %@ (Size : %u bytes)",musicFile,soundData.length);
    
    [player setDelegate:self];
    
    player.numberOfLoops=-1;
    [player prepareToPlay];
    return [super init];
    
}

-(NSString *) startPlaying
{
    [player play];
    
    //NSLog(@"Player Started playing");
    return @"<PLAYER STARTED/>";
}

-(NSString *) stopPlaying
{
    [player stop];
    //NSLog(@"Player Stoped");
    return @"<PLAYER STOPED/>";
}

-(NSString *) setVolume:(NSString *)volume
{   float vol;
    vol=[volume floatValue];
    vol/=100;
    player.volume=vol;
    return @"<OK />";
}

//AVAudioPlayerDelegate methods

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *) aplayer successfully:(BOOL) flag
{
    //NSLog(@"Played Successfully : %c", flag);
    //self.player=nil;
    //[aplayer release];
    //  self.recordButton.enabled=YES;
    // self.stopButton.enabled=NO;
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                error:(NSError *)error
{
    //NSLog(@"Decode Error occurred");
}

@end
