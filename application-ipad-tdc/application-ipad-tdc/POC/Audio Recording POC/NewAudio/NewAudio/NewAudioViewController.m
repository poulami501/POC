//
//  NewAudioViewController.m
//  NewAudio
//
//  Created by Chinmay Kulkarni on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewAudioViewController.h"

@implementation NewAudioViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    play.enabled = NO;
    stop.enabled = NO;
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.aac"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
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
    
    recorder = [[AVAudioRecorder alloc]
                     initWithURL:soundFileURL
                     settings:recordSettings
                     error:&error];
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [recorder prepareToRecord];
    }
}

-(IBAction) startRecording:(id)sender{
    if (!recorder.recording)
    {
        play.enabled = NO;
        stop.enabled = YES;
        [recorder record];
    }
}

-(IBAction)stop :(id)sender{
    stop.enabled = NO;
    play.enabled = YES;
    record.enabled = YES;
    
    if (recorder.recording)
    {
        [recorder stop];
    }
}

-(IBAction) play:(id)sender{
    if (!recorder.recording)
    {
        stop.enabled = YES;
        record.enabled = NO;
        
        if (player)
            [player release];
        NSError *error;
        
        NSArray *dirPaths;
        NSString *docsDir;
        
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"speech.mp3"];
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
//        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:&error];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        if (error)
            NSLog(@"Error: %@", [error localizedDescription]);
        else
            [player play];
        
//        NSDictionary *settings = player.settings;
//        NSString *bitRate = [settings objectForKey:AVEncoderBitRateKey];
//        printf("\nBit Rate: %s\n",[bitRate UTF8String]);
        player.delegate = self;
    }
}

-(void)audioRecorderDidFinishRecording: (AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if(flag)
    printf("\nRecording done\n");
}

-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder 
                                  error:(NSError *)error
{
    NSLog(@"Encode Error:%@",error);
}

-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    record.enabled = YES;
    stop.enabled = NO;
}
-(void)audioPlayerDecodeErrorDidOccur:
(AVAudioPlayer *)player 
                                error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

-(void) dealloc{
    [recorder release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
