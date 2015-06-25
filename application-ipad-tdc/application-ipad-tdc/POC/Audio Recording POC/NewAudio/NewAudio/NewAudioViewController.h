//
//  NewAudioViewController.h
//  NewAudio
//
//  Created by Chinmay Kulkarni on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface NewAudioViewController : UIViewController<AVAudioRecorderDelegate,AVAudioPlayerDelegate>{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    IBOutlet UIButton *record;
    IBOutlet UIButton *stop;
    IBOutlet UIButton *play;
}
-(IBAction) startRecording:(id)sender;
-(IBAction) stop:(id)sender;
-(IBAction) play:(id)sender;
@end
