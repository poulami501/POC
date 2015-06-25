// Created by Sabyasachi shadangi on 04/08/2012.
// Copyright 2012 sabyasachi shadangi. All rights reserved.



#import "DelegatePlugin.h"



@implementation DelegatePlugin


@synthesize requestHandler;
@synthesize ttsUtil;
@synthesize audioRecorder;



- (void) execute:(NSMutableArray *)arguments withDict:(NSDictionary *) options {
    ////NSLog(@"Inside class DelegatePlugin, execute method called");
  CDVPluginResult * result = nil;
  NSString * xmlData = nil;
    

  @try {
   
      NSString *callbackID = [arguments pop];
    NSString *jsonString = [arguments objectAtIndex:0];
      NSRange  startTag = [jsonString rangeOfString:@"<"];
      NSRange endTag = [jsonString rangeOfString:@">" options:NSBackwardsSearch];
      
      if (startTag.location!=NSNotFound&&endTag.location!=NSNotFound) {
          NSRange xmlRange = {startTag.location+startTag.length,endTag.location-startTag.location-startTag.length};
          NSString *modifiedJsonString = [jsonString stringByReplacingOccurrencesOfString:@"\"" withString:@"&#" options:0 range:xmlRange];
          [arguments removeObject:jsonString];
          [arguments addObject:modifiedJsonString];
      }
      //NSData * data = [[NSData alloc] initWithBytes:[[arguments objectAtIndex:0] UTF8String] length:[[arguments objectAtIndex:0] length]] ;
     
      NSString *jsonObj=[arguments objectAtIndex:0] ;
      
      //jsonObj = [DelegatePlugin stringByRemovingControlCharacters:jsonObj];
      
      NSData *data=[jsonObj dataUsingEncoding:NSUTF8StringEncoding];
      
      NSError *error = nil;
      
      NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error]];
      
      NSString * modifiedString = [jsonData objectForKey:@"xml_string"];
      
      NSString *originalString = [modifiedString stringByReplacingOccurrencesOfString:@"&#" withString:@"\""];
      [jsonData setObject:originalString forKey:@"xml_string"];
      
      if (error) {
          //NSLog(@"%@",[error description] );
      }
      
      NSString *method = [jsonData objectForKey:@"method"];
      NSString *xmlString = [jsonData objectForKey:@"xml_string"];
      NSString *className = [jsonData objectForKey:@"class_name"];
      
      //////////
      ////NSLog(@"************%@************",@"REQUEST");
      ////NSLog(@"============%@============",method);
      ////NSLog(@"%@",xmlString);
      ////NSLog(@"============%@============",className);
      
      ///////////
      
     
      if (!requestHandler) {
      requestHandler=[[RequestHandler alloc]init];
      }
      
      
      
      
      if([className isEqualToString:@"PersistenceAction"])
         {
      if ((method != nil) && (![method isEqualToString:@"none"])) {
          ////NSLog(@"Handle event %@ with %@",method,xmlString);
       xmlData = [requestHandler handleEvent:method withJSONData:xmlString];
          ////NSLog(@"=============RESPONSE===========");
          ////NSLog(@"%@",xmlData);
          result =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:xmlData
                   ];
     //  //NSLog(@"\nxmlData is :%@",xmlData);
              // Call the javascript success function
      [self writeJavascript: [result toSuccessCallbackString:callbackID]];
          
      }

      }
      else if ([className isEqualToString:@"ContentAction"])
      {
          xmlData = [requestHandler handleEvent:method withJSONData:xmlString];
          ////NSLog(@"************RESPONSE************");
          ////NSLog(@"%@",xmlData);
          result =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:xmlData];
          ////NSLog(@"*******After SuccessCallBack*******\n%@",xmlData);
       
          [self writeJavascript: [result toSuccessCallbackString:callbackID]];
          
    

      }
      else if ([className isEqualToString:@"SpeechAction"])
      {
          if (!ttsUtil) {
              
              ttsUtil=[[TTSUtil alloc]init];
          }

          //To stop reading text
          if([xmlString isEqualToString:@"STOP_READ_TEXT"])
          {
              NSString *msg;
              //check if TTSutil has been playing or not
              if (ttsUtil) {
                  msg=[ttsUtil stopReading];
              }
              
              //result =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
              //[self writeJavascript: [result toSuccessCallbackString:callbackID]];
          }
          else if([method isEqualToString:@"isPlaying"])
          {
              NSString *msg = [ttsUtil playStatus];
              result =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
              [self writeJavascript: [result toSuccessCallbackString:callbackID]];
          }
          else if ([method isEqualToString:@"setVolume"])
          {
              NSString *msg=[ttsUtil setVolume:xmlString];
              result =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
              [self writeJavascript: [result toSuccessCallbackString:callbackID]];
          }
          else //For reading text
          {
          NSString *text=method;
              
          NSString *speedValue=xmlString;
                   
          NSString *msg =[ttsUtil execSpeechRequestWithText:text andSpeedValue:speedValue];
          result =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
          [self writeJavascript: [result toSuccessCallbackString:callbackID]];
          }
      }
      else if ([className isEqualToString:@"SoundRecorderAction"])
      {
          NSString *fileName=xmlString;
          NSString *msg;
          
          if (!audioRecorder) {
              
              audioRecorder=[[AudioRecorderUtils alloc] initWithFileName:fileName];
              
          }
          
          if ([method isEqualToString:@"record"]) {
              msg=[audioRecorder startRecording];
          } else if ([method isEqualToString:@"stop"]){
              msg=[audioRecorder stopRecording];
          }else if ([method isEqualToString:@"reset"]){
              msg=[audioRecorder reset];
              audioRecorder=nil;
          }
          ////NSLog(@"=============RESPONSE===========");
          ////NSLog(@"%@",msg);
          
          result =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
          [self writeJavascript: [result toSuccessCallbackString:callbackID]];
          
          if ([method isEqualToString:@"record"]) {
           
          }
          
      } else if ([className isEqualToString:@"TestSecurityAction"])
      {
          if ([method isEqualToString:@"checkForScreenshot"]) {
              [TestSecurityUtils updatePhotoCount];
          }
      }
      else if ([className isEqualToString:@"UtilityAction"])
      {
          //NSString *method=xmlString;
          if([method isEqualToString:@"exit"])
          {
             // [UtilityAction deleteCache];
              [UtilityAction clearSavedUser];
          }
          else if ([method isEqualToString:@"isRestart"])
          {
              NSString *msg;
              
              msg=[UtilityAction isRestart];
              result =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
              [self writeJavascript: [result toSuccessCallbackString:callbackID]];
          }
          
          
      }
      
          }
  @catch (NSException *exception) {

      ////NSLog(@"JSON Exception%@",[exception reason]);
      //NSLog(@"Exception in Delegate Plugin :%@",[exception description]);
      
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION];
  }
}

+ (NSString *)stringByRemovingControlCharacters: (NSString *)inputString
{
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    NSRange range = [inputString rangeOfCharacterFromSet:controlChars];
    if (range.location != NSNotFound) {
        NSMutableString *mutable = [NSMutableString stringWithString:inputString];
        while (range.location != NSNotFound) {
            [mutable deleteCharactersInRange:range];
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return inputString;
}

@end
