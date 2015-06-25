// Created by Sabyasachi shadangi on 04/08/2012.
// Copyright 2012 sabyasachi shadangi. All rights reserved.




#import <Cordova/CDV.h>
#import "PersistenceAction.h"
#import "RequestHandler.h"
#import "TTSUtil.h"
#import "AudioRecorderUtils.h"
#import "TestSecurityUtils.h"
#import "UtilityAction.h"
@interface DelegatePlugin : CDVPlugin

@property (strong, nonatomic) RequestHandler *requestHandler;
@property (strong, nonatomic) TTSUtil * ttsUtil;
@property (strong, nonatomic) AudioRecorderUtils *audioRecorder;

- (void) execute:(NSMutableArray *)arguments withDict:(NSDictionary *) options;
+ (NSString *)stringByRemovingControlCharacters: (NSString *)inputString;

@end
