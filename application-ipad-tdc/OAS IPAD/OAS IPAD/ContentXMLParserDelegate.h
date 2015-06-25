//
//  ContentXMLParserDelegate.h
//  CordovaDemo
//
//  Created by Shayan Roychoudhury on 9/17/12.
//
//

#import <Foundation/Foundation.h>

@interface ContentXMLParserDelegate : NSXMLParser <NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableDictionary *imageData;
@property (strong, nonatomic) NSString *zipData;

@end
