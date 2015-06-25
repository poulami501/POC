
// Created by Sabyasachi shadangi on 05/08/2012.
// Copyright 2012 sabyasachi shadangi. All rights reserved.


#import "TTSUtil.h"


@implementation TTSUtil

@synthesize player;
@synthesize responseData;
@synthesize playerObserver; 

- (id) init {
  if (self = [super init]) {
  } 
    responseData = [[NSMutableData alloc] init] ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
     return self;
}


- (void)unloadCache:(NSNotification*) notification {
    // Flush all cached data
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


- (NSString *) execSpeechRequestWithText:(NSString *)text andSpeedValue:(NSString *)speedValue{
    isplaying=@"not started";
 
 if ([speedValue isEqualToString:@"-1"]) {
     speedValue = @"175";
 }
 else if ([speedValue isEqualToString:@"-2"]) {
     speedValue = @"100";
 }
 else if ([speedValue isEqualToString:@"-3"]) {
         speedValue = @"75";
 }
 else
 {
     speedValue=@"100";
 }    
    
    text=[text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    text=[TTSUtil decodeHtmlUnicodeCharactersToString:text];
    //NSLog(@"TTS text : %@",text);
    
    NSString *postString = [NSString stringWithFormat:@"customerid=5857&lang=en_us&output=audiolink&text=%@&voice=Kate&speed=%@",text,speedValue];
    
    ////NSLog(@"post String: %@",postString);
    
    NSURL *url = [NSURL URLWithString:@"https://app.readspeaker.com/cgi-bin/rsent"];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d",[postString length]];
    
    //TODO: set your content type
    [req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"ac678cf868483de0b733cf4d81b6367b" forHTTPHeaderField:@"x-readspeaker-api-key"];
   // [req addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    if (theConnection) {
        ////NSLog(@"Connection established using new TTS parameters");
    }
    
        ////NSLog(@"Problem in establishing the Connection");
    
  return @"<OK />";
}


-(NSString *)playStatus
{
    ////NSLog(@"Play Status : %@",isplaying);
    return isplaying;
    
}

#pragma mark URLConnection Delegate Methods
-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
   
    NSString *xml = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];   
    ////NSLog(@"Received data **********************: %@",xml);
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [rootPath stringByAppendingPathComponent:@"speech.mp3"];
    
    xml=[xml stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    xml=[xml stringByReplacingOccurrencesOfString:@"%0D%0A" withString:@""];
    
    NSURL *mp3URL =[NSURL URLWithString:xml];
    NSData *musicData=[[NSData alloc]initWithContentsOfURL:mp3URL];
    [musicData writeToFile:path atomically:YES];
    ////NSLog(@"MP3 stored at %@",path);
    
    NSError *error=nil;
    player=[[AVAudioPlayer alloc]initWithData:musicData error:&error ];
    
    if (!error) {
        
        [self setVolume:playerVolume];
        [player setDelegate:self];
        [player play];
        isplaying=@"playing";
        
    }
    else
    {
        isplaying=@"finished";    
        ////NSLog(@"Error while allocating Music Player");
        
    }         
    
}

+(NSString *)decodeHtmlUnicodeCharactersToString:(NSString *) text
{
    
    NSMutableString* string = [[NSMutableString alloc] initWithString:text];
    NSString* unicodeStr = nil;
    NSString* replaceStr = nil;
    int counter = -1;
    unichar char1;
    unichar char2;
    
    for(int i = 0; i < [string length]; ++i)
    {
         char1= [string characterAtIndex:i];
        
        if (char1 != '&')
            continue;
        
        if(i<[string length]-1)
        char2 = [string characterAtIndex: i+1];
        
        if (char1 == '&'  && char2 == '#' )
        {
            ++counter;
            NSInteger unicodeEnd = 5;
            
            if(string.length < i + 7) {
                unicodeEnd = string.length - (i + 2);
            }
            ////NSLog(@"Unicode : %lu",unicodeEnd);
            NSRange range = [ [string substringWithRange:NSMakeRange (i + 2, unicodeEnd)]
                             rangeOfString:@";"];
            
            if(range.location != NSNotFound) {
                
                // read integer value i.e, 39
                unicodeStr = [string substringWithRange:NSMakeRange(i + 2 , range.location)];
                ////NSLog(@"Unicode : %@",unicodeStr);
                
                // #&39;
                replaceStr = [string substringWithRange:NSMakeRange (i, range.location + 3)];
                ////NSLog(@"replaceStr : %@",replaceStr);
                
                unichar character = (unichar)[unicodeStr intValue];
                
                // replace unicode char with actual char
                [string replaceCharactersInRange: [string rangeOfString:replaceStr] withString:[NSString stringWithFormat:@"%C",character]];
                
            }
        }
    }
    [string setString: [string stringByReplacingOccurrencesOfString:@"<b>" withString:@""]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"</b>" withString:@""]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"<i>" withString:@""]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"</i>" withString:@""]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"<u>" withString:@""]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"</u>" withString:@""]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"<br>" withString:@""]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@""]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"</br>" withString:@""]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"%" withString:@"percent"]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"+" withString:@"plus"]];
    [string setString: [string stringByReplacingOccurrencesOfString:@"&" withString:@"and"]];
    
    ////NSLog(@" Final String for TTS Post :%@ ",string);
    return string;
}

-(NSString *) setVolume:(NSString *)volume
{   float vol;
    playerVolume=volume;
    vol=[volume floatValue];
    vol/=100;
    player.volume=vol;
    return @"<OK />";
}

-(NSString *)stopReading
{
    [player stop];
    isplaying=@"finished";
    return @"<READING STOPPED />";
}

- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
      NSURLCredential *credential = [NSURLCredential credentialWithUser:@"oasclient" password:@"oastts" persistence:NSURLCredentialPersistenceForSession];    
    
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [responseData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [responseData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //NSLog(@"Connection failed with error: %@",error);
    
    isplaying=@"finished";
}

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *) aplayer successfully:(BOOL) flag
{
    //NSLog(@"Played Successfully : %@", flag?@"YES":@"NO");
    isplaying=@"finished";
    player=nil;
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
error:(NSError *)error
{
    isplaying=@"finished";
    ////NSLog(@"Decode Error occurred");
}
@end
