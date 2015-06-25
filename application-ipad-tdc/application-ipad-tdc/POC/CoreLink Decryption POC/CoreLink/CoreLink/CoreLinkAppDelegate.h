//
//  CoreLinkAppDelegate.h
//  CoreLink
//
//  Created by Chinmay Kulkarni on 7/30/12.
//  Copyright (c) 2012 __TCS__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <speex/speex.h>

@class CoreLinkViewController;

@interface CoreLinkAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CoreLinkViewController *viewController;

@end
