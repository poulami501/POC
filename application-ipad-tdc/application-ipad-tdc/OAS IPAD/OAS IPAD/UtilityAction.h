//
//  UtilityAction.h
//  OAS IPAD
//
//  Created by CTB on 16/04/13.
//  Copyright (c) 2013 mcgrawhill ctb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilityAction : NSObject

+(void) deleteCache;
+(void) clearSavedUser;
+(void)saveUser:(NSString *)userId Password:(NSString *) password AccessCode: (NSString *)accessCode;
+(NSString *) isRestart;
+(Boolean) isTimerValid;

@end
