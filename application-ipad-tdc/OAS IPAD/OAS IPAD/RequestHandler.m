//
//  RequestHandler.m
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 10/5/12.
//  Copyright (c) 2012 mcgrawhill ctb. All rights reserved.
//  Prod workspace

#import "RequestHandler.h"

@implementation RequestHandler

@synthesize ca;
@synthesize pa;
@synthesize theWeb;
@synthesize recordedAudioFileName;

- (id) init {
    if (self = [super init]) {
    }
    //NSLog(@"Initiating RequestHandler");
    ca=[[ContentAction alloc] init];    
    pa=[[PersistenceAction alloc]init];
    return self;
}


/**
 * The handleEvent method of the class.
 *
 * call the method based on each event, return result response xml to client
 *
 *
 */


- (NSString *) handleEvent:(NSString *)method withJSONData:(NSString *)xml{
    @try {
        NSString *result = @"<OK />";
        if (method!=nil) {
            if ([[method lowercaseString]isEqualToString:@"login"]) {
                result =[pa login:xml];
                ca.contentURI=pa.contentURI;
                //[ContentAction deleteCache];
                
            } else if([method isEqualToString:@"save"]){
                NSLog(@"Save call");
                result=[pa save:xml];
            }
            else if([method isEqualToString:@"feedback"]){
                [pa feedback:xml];
            }
            else if([method isEqualToString:@"getSubtest"]){
                //NSLog(@"Getting Subtest");
                
                result =[ca getSubtest:xml];
            }
            else if([method isEqualToString:@"downloadFileParts"]){
                //NSLog(@"Getting file parts");
                
                result =[ca downloadFileparts:xml];
            }
            else if([method isEqualToString:@"downloadItem"]){
                //NSLog(@"Downloading Item");
                
                result =[ca downloadItem:xml];
            }
            else if([method isEqualToString:@"getItem"]){
                //NSLog(@"Getting Item");
                            result =[ca getItem:xml];
            }
            else if([method isEqualToString:@"getImage"]){
                //NSLog(@"Getting Image");
       
                    result =[ca getImage:xml];
            }
            else if([method isEqualToString:@"writeToAuditFile"]){
                //NSLog(@"Writing to AuditFile");
                result =[pa writeToAuditFile:xml];
            }
            else if([method isEqualToString:@"uploadAuditFile"]){
                //NSLog(@"Uploading AuditFile");
                result =[pa writeToAuditFile:xml];
            }
            else if([method isEqualToString:@"getMusicData"]){
                //NSLog(@"Getting Music Data");
                result =[ca getMusicData:xml];
            }
            else if([method isEqualToString:@"playMusicData"]){
                //NSLog(@"Playing Music");
                result=[ca playMusic:xml];
            }
            else if([method isEqualToString:@"stopMusicData"]){
                //NSLog(@"Stoping Music");
                result=[ca stopMusic:xml];
            }
            else if([method isEqualToString:@"setVolume"]){
                //NSLog(@"Setting Music Volume");
                result=[ca setVolume:xml];
            }
            else if([method isEqualToString:@"getTEItems"]){
                //NSLog(@"Getting TE ITems Path");
                result=[ca getTEItemsPath];
            }
            
            else if([method isEqualToString:@"isProductCheck"]){
                //NSLog(@"Getting Product Type");
                result=[pa getProductType];
            }
            else if([method isEqualToString:@"isGuidedAccess"]){
                //NSLog(@"Checking for Guided Access");
                result=[PersistenceAction isGuidedAccessEnabled];
            }
            else if([method isEqualToString:@"updateRequired"]){
                 result=[PersistenceAction updateRequired];
               
                [theWeb stringByEvaluatingJavaScriptFromString:@"unblockiPADUI();"];
                
            }
            else
                NSLog(@"invalid method");
        }
        else{
            NSLog(@"No method received");
        }
        return result;
    }
    @catch (NSException *exception) {
        NSLog(@"Excpetion in handle event method :%@",[exception reason]);
    }
    
}


@end
