//
//  CoreLinkViewController.h
//  CoreLink
//
//  Created by Chinmay Kulkarni on 7/30/12.
//  Copyright (c) 2012 __TCS__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonCryptor.h>
//#import <speex/speex.h>
//
//#define kNumberBuffers 3
//#define kNumVolumeSamples 10
//#define kSilenceThresholdDB -30.0
//
//#define kVolumeSamplingInterval 0.05
//#define kSilenceTimeThreshold 0.9
//#define kSilenceThresholdNumSamples kSilenceTimeThreshold / kVolumeSamplingInterval

//typedef struct AQRecorderState {
//    AudioStreamBasicDescription  mDataFormat;                   
//    AudioQueueRef                mQueue;                        
//    AudioQueueBufferRef          mBuffers[kNumberBuffers];                    
//    UInt32                       bufferByteSize;                
//    SInt64                       mCurrentPacket;                
//    bool                         mIsRunning;
//    
//    SpeexBits                    speex_bits; 
//    void *                       speex_enc_state;
//    int                          speex_samples_per_frame;
//    __unsafe_unretained NSMutableData *              encodedSpeexData;
//    
//    __unsafe_unretained id selfRef;
//} AQRecorderState;


@interface CoreLinkViewController : UIViewController{
//    UIAlertView *status;
//    
//    AQRecorderState aqData;
//    
//    BOOL detectedSpeech;
//    int samplesBelowSilence;
//    
//    NSTimer *meterTimer;
//    BOOL processing;
//    
//    NSMutableArray *volumeDataPoints;
//    
//    NSThread *processingThread;
}
//@property (readonly) BOOL recording;

//- (id)initWithCustomDisplay:(NSString *)nibName;
//
//// Begins a voice recording
//- (void)beginRecording;
//
//// Stops a voice recording. The startProcessing parameter is intended for internal use,
//// so don't pass NO unless you really mean it.
//- (void)stopRecording:(BOOL)startProcessing;

-(void) parseJSON:(NSString *) filename;
- (void)removeFile:(NSString *)filename;
-(void) decryptFile:(NSString *) fileName WithHash:(NSString *) hash WithKey:(NSString *)key;
-(void) decryptMP3File:(NSString *) fileName WithKey:(NSString *)key;
+ (NSString *) encode:(NSData *)bytes;
+ (NSString *) decodeToByteArray:(NSString *)src;
+ (char) getBaseTableIndex:(unichar)c ;
@end
