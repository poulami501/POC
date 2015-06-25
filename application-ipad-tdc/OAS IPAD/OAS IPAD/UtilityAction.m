//
//  UtilityAction.m
//  OAS IPAD
//
//  Created by CTB on 16/04/13.
//  Copyright (c) 2013 mcgrawhill ctb. All rights reserved.
//

#import "UtilityAction.h"

@implementation UtilityAction

+(void) deleteCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *files=[fileManager contentsOfDirectoryAtPath:path error:nil];
    //NSArray *files=[fileManager directoryContentsAtPath:path];
    NSError *error=nil;
    for (NSString *file in files) {
        [fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
        
        if (error) {
            NSLog(@"Error while deleting %@",[path stringByAppendingPathComponent:file]);
        }
    }
    
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    NSLog(@"The path is %@",path);
    fileManager=[NSFileManager defaultManager];
    files=[fileManager contentsOfDirectoryAtPath:path error:nil];
    error=nil;
    for (NSString *file in files) {
        [fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
        NSLog(@"Deleting %@",file);
        if (error) {
            NSLog(@"Error while deleting %@",[path stringByAppendingPathComponent:file]);
        }
    }

}



+(void)saveUser:(NSString *)userId Password:(NSString *) password AccessCode: (NSString *)accessCode
{
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath=[cachePath stringByAppendingPathComponent:@"crash.save"];
    
    NSString *saveString=[NSString stringWithFormat:@"<loginData isRestart=\"true\" loginId=\"%@\" password=\"%@\" accessCode=\"%@\"></loginData>",userId,password,accessCode];
    
    [saveString writeToFile:cachePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    
    NSLog(@"Credentials saved at %@",cachePath);
    
}

+(NSString *) isRestart
{
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath=[cachePath stringByAppendingPathComponent:@"crash.save"];
    
    NSError *err;
    NSString *saveString=[[NSString alloc]initWithContentsOfFile:cachePath encoding:NSUTF8StringEncoding error:&err];
    /*if (err && ![UtilityAction isTimerValid]) {
        NSLog(@"crash. save not found at %@",cachePath);
        saveString=@"<loginData isRestart=\"false\" loginId=\"\" password=\"\" accessCode=\"\"> </loginData>";
    }*/
    
    if(!UIAccessibilityIsGuidedAccessEnabled())
    {
        NSLog(@"No guided Access!!");
        saveString=@"<loginData isRestart=\"false\" loginId=\"\" password=\"\" accessCode=\"\"> </loginData>";
    }
    
    if (![UtilityAction isTimerValid]) {
        NSLog(@"Timer invalid!!");
        saveString=@"<loginData isRestart=\"false\" loginId=\"\" password=\"\" accessCode=\"\"> </loginData>";
    }
    
    if (err)
    {
        NSLog(@"crash. save not found at %@",cachePath);
        saveString=@"<loginData isRestart=\"false\" loginId=\"\" password=\"\" accessCode=\"\"> </loginData>";
    }
    
    return saveString;
}

+(Boolean) isTimerValid
{
    NSError *err;
    double savedTime;
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath=[cachePath stringByAppendingPathComponent:@"time.save"];
    NSString *timeString=[NSString stringWithContentsOfFile:cachePath encoding:NSUTF8StringEncoding error:&err];
    savedTime=[timeString floatValue];
    
    if(err)
    {
        return NO;
    }
    
    if(CFAbsoluteTimeGetCurrent()>savedTime+30)
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
}

+(void) clearSavedUser
{
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath=[cachePath stringByAppendingPathComponent:@"crash.save"];
   
     [UIPasteboard generalPasteboard].string=@"";
    [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];

}
@end
