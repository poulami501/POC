//
//  TestProtocol.m
//  OAS IPAD
//
//  Created by CTB on 14/10/14.
//  Copyright (c) 2014 mcgrawhill ctb. All rights reserved.
//

#import "TICalculatorURLProtocol.h"

@implementation TICalculatorURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    NSString *scheme = [[request URL] scheme];
    //NSLog(@"Trying to load :%@ !!!!!! Protocol:%@",[[request URL] absoluteString],scheme);
    
    if([scheme isEqualToString:@"calc"])
    {
        return YES;
    }
    return NO;
    
    //return [super canInitWithRequest:request];
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)theRequest
{
    return theRequest;
}

- (void)startLoading {


    //NSLog(@"Servicing Calc request!!!");
    
    //This method retrieves the data from the actual file in the app packages
    NSURLRequest *request = [self request];
    NSString *fileNameWithExtension=[[request URL] lastPathComponent];
    NSString *folderName=[[[[request URL] absoluteString] stringByDeletingLastPathComponent] stringByReplacingOccurrencesOfString:@"calc:/" withString:@""] ;
    NSString *fileExtension=[fileNameWithExtension pathExtension];
    NSString *fileName=[fileNameWithExtension stringByDeletingPathExtension];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension inDirectory:folderName ];
    
    //NSLog(@"Loading %@",path);
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    //Do a mock request to return the data as response
    [self mockRequest:request data:data];
    
}

- (void)stopLoading
{
    NSLog(@"Did stop loading");
}

-(void) mockRequest:(NSURLRequest*)request data:(NSData*)data {
    id client = [self client];
    
    NSDictionary *headers = @{@"Access-Control-Allow-Origin" : @"*", @"Access-Control-Allow-Headers" : @"Content-Type"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"1.1" headerFields:headers];
    
    [client URLProtocol:self didReceiveResponse:response
     cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [client URLProtocol:self didLoadData:data];
    [client URLProtocolDidFinishLoading:self];
}






@end
