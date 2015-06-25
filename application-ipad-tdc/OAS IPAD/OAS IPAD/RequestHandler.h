//
//  RequestHandler.h
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 10/5/12.
//  Copyright (c) 2012 mcgrawhill ctb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginResponseParser.h"
#import "ResponseParser.h"
#import "ContentAction.h"
#import "PersistenceAction.h"

@interface RequestHandler : NSObject


@property (strong, nonatomic) ContentAction *ca;
@property (strong, nonatomic) PersistenceAction *pa;
@property (strong, nonatomic) NSString *recordedAudioFileName;
@property (strong, nonatomic) UIWebView *theWeb;
- (id) init;
- (NSString *) handleEvent:(NSString *)method withJSONData:(NSString *)json;


@end
