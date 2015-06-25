//
//  LoginResponseParser.h
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 9/21/12.
//  Copyright (c) 2012 mcgrawhill ctb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseParser : NSXMLParser <NSXMLParserDelegate>

@property(strong) NSMutableDictionary *trackerinfo;

-(id) initWithString:(NSString *)string;
-(NSString *) getAtrtributeValue:(NSString *) attributName;
-(void) setElement:(NSString * ) elementName;
@end
