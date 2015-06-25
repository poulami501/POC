//  MainViewController.h
//  OAS IPAD
//
//  Created by sabyasachi shadangi on 9/6/12.
//  Copyright mcgrawhill ctb 2012. All rights reserved.

#import "MainViewController.h"
#import "TICalculatorURLProtocol.h"
#import <objc/runtime.h>

//Macro for determining ios version
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation MainViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    maxMemoryCount=SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?8:3; // set the max memory warnings to trigger app refresh
    if (self) {
        firstLoad=YES;
        
        //register selectors for keyboard related notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidChangeFrameNotification object:nil];
        //Guided Access
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guidedAccessChanged:) name:UIAccessibilityGuidedAccessStatusDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenshotTaken:) name:@"ScreenshotTakenNotification"
                                                   object:nil];
        
        //To disable screenlock
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        //Setting delegate to  self to use canPerformAction for customised long press context menu
        [self.webView setDelegate:self];
        
        
        //NSLog(@"Can undo:?? %@",[[[self webView] undoManager] canUndo]?@"Yes":@"No!!");

        SEL originalSelector =NSSelectorFromString(@"_nextAccessoryTab");
        SEL swizzledSelector = @selector(nextTab:);
        Method originalMethod = class_getInstanceMethod(self.webView.class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self.class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(self.webView.class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            NSLog(@"Did add method");
            class_replaceMethod(self.webView.class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
            
        } else {
            
            NSLog(@"Exchanged method");
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        
    }
    return self;
}

//method to find UIWebBrowserView in webview and replace it's canPerformAction:withSender: with our own
- (void) replaceCanPerformActionInSubviewOf: (UIView *)view
{
    
    for (UIView *sub in view.subviews) {
        [[sub undoManager] disableUndoRegistration];
        //[self replaceCanPerformActionInSubviewOf:sub];
        
        NSLog(@"%@ --> %@",NSStringFromClass(view.class), NSStringFromClass(sub.class));
        
        //find UIWebBrowserView
        if ([NSStringFromClass([sub class]) isEqualToString:@"UIWebBrowserView"]) {
            
            Class class = sub.class;
            
            SEL originalSelector = @selector(canPerformAction:withSender:);
            SEL swizzledSelector = @selector(mightPerformAction:withSender:);
            SEL crInFocusSelector = @selector(isCRinFocus);
            SEL crTextSelector = @selector(isTextSelected);
            SEL crEmptyCheckSelector = @selector(isCREmpty);
            
            Method crFocusMethod = class_getInstanceMethod(self.class, crInFocusSelector);
            Method crTextMethod = class_getInstanceMethod(self.class, crTextSelector);
            Method crEmptyMethod = class_getInstanceMethod(self.class, crEmptyCheckSelector);
            
            
            //Add CR text utility methods to UIWebBrowserView
            class_addMethod(class,
                            crInFocusSelector,
                            method_getImplementation(crFocusMethod), method_getTypeEncoding(crFocusMethod));
            /*NSLog(@"%@",class_addMethod(class,
                            crInFocusSelector,
                            method_getImplementation(crFocusMethod),
                            method_getTypeEncoding(crFocusMethod))?@"Added crInFocusSelector":@"Failed to add crInFocusSelector");*/
            class_addMethod(class,
                            crTextSelector,
                            method_getImplementation(crTextMethod),
                            method_getTypeEncoding(crTextMethod));
            /*NSLog(@"%@",class_addMethod(class,
                                        crTextSelector,
                                        method_getImplementation(crTextMethod),
                                        method_getTypeEncoding(crTextMethod))?@"Added crTextSelector":@"Failed to add crTextSelector");*/
            class_addMethod(class,
                            crEmptyCheckSelector,
                            method_getImplementation(crEmptyMethod),
                            method_getTypeEncoding(crEmptyMethod));
            /*NSLog(@"%@",class_addMethod(class,
                                        crEmptyCheckSelector,
                                        method_getImplementation(crEmptyMethod),
                                        method_getTypeEncoding(crEmptyMethod))?@"Added crTextSelector":@"Failed to add crTextSelector");*/
            
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self.class, swizzledSelector);
            
            
            //Add the delegate's mightPerformAction to the UIWebBrowserView
            BOOL didAddMethod =
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            
            
            //replace the UIWebBrowserView canPerformAction with the delegates mightPerformAction
            if (didAddMethod) {
                NSLog(@"Did add method");
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
                
            } else {
                
                NSLog(@"Exchanged method");
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    }
}



//Custom handling for long press context menu
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //    UIMenuController *menuController = [UIMenuController sharedMenuController];
    //    if (menuController) {
    //        [[super webView] stringByEvaluatingJavaScriptFromString:@"window.getSelection().removeAllRanges();"];
    //        [UIMenuController sharedMenuController].menuVisible = NO;
    //    }
    
    //prevents the action from bubbling up the responder chain
    return NO;
}

//- (NSArray *)keyCommands {
//    return @[
//             [UIKeyCommand keyCommandWithInput:@"c" modifierFlags:UIKeyModifierCommand action:@selector(cmdC:)],
//             [UIKeyCommand keyCommandWithInput:@"v" modifierFlags:UIKeyModifierCommand action:@selector(cmdV:)]
//             ];
//}

//- (void)cmdV:(id)sender {
//    NSLog(@"CMD + V!!!!");
//    [self paste:sender];
//}
//- (void)cmdC:(id)sender {
//    NSLog(@"CMD + C!!!!");
//    
//    [self copy:sender];
//}




- (BOOL)mightPerformAction:(SEL)action withSender:(id)sender {
   
   
    //NSLog(@"### %@ : %@",NSStringFromSelector(action),NSStringFromClass(self.class));
    
    
   
    if (action == @selector(select:))
    {
        if ([self isCREmpty] || [self isTextSelected]) {
            return NO;
        }
        else
        {
            return YES;
        }
        NSLog(@"select Selector");
        
    }
    else if (action == @selector(selectAll:))
    {
        NSLog(@"selectAll Selector");
        
        if ([self isCREmpty] || [self isTextSelected]) {
            return NO;
        }
        else
        {
            return YES;
        }
        //        return  [super canPerformAction:action withSender:sender];
    }
    else if (action == @selector(cut:))
    {
        NSLog(@"cut Selector");
        if ([self isTextSelected]) {
            return YES;
        }
        else
        {
            return NO;
        }
        //        return  [super canPerformAction:action withSender:sender];
    }
    else if (action == @selector(copy:))
    {
        NSLog(@"copy Selector");
        //Allow copy only if text is selected in CR
        if ([self isTextSelected]) {
            return YES;
        }
        else
        {
            return NO;
        }
        //        return  [super canPerformAction:action withSender:sender];
    }
    else if (action == @selector(paste:))
    {
        NSString *pasteBoardString=[UIPasteboard generalPasteboard].string;
        NSLog(@"paste Selector");
        //Allow paste only if CR is in focus & there is something to paste
        if ([self isCRinFocus] && !(pasteBoardString == (id)[NSNull null] || pasteBoardString.length == 0) ) {
            //NSLog(@"UI PasteboARD %@",pasteBoardString);
            return YES;
        }
        else
        {
            return NO;
        }
        //        return  [super canPerformAction:action withSender:sender];
    }
    else
    {
        return NO;
    }
    
    return YES;
    
}



//CR text utility methods
-(BOOL) isCRinFocus
{
    NSString *result = [[self webView] stringByEvaluatingJavaScriptFromString:@"isCRinFocus()"];
    if ([result isEqual:@"true"]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL) isTextSelected
{
    NSString *result = [[self webView] stringByEvaluatingJavaScriptFromString:@"isTextSelected()"];
    if ([result isEqual:@"true"]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL) isCREmpty
{
    NSString *result = [[self webView] stringByEvaluatingJavaScriptFromString:@"isCREmpty()"];
    if ([result isEqual:@"true"]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) didReceiveMemoryWarning
{
    
    memoryWarningCount++;
    NSLog(@"Warning Count: %d",memoryWarningCount);
    
    //check the number of memory warnings to determine whether to refresh or not
    if (memoryWarningCount>maxMemoryCount) {
        [[super webView] stringByEvaluatingJavaScriptFromString:@"window.open(\"dummy.html\",'_self');"];
        memoryWarningCount=0;
        isRedirect=YES;
        
    }
    
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void) viewDidLoad
{
    //Register new NSURLProtocol class to load TI-Calculator from app package
    [NSURLProtocol registerClass:[TICalculatorURLProtocol class]];
    [super viewDidLoad];
    [self replaceCanPerformActionInSubviewOf:self.webView];
    
    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /*   CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
     
     self.webView.frame = viewBounds; */
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

/* Comment out the block below to over-ride */
/*
 - (CDVCordovaView*) newCordovaViewWithFrame:(CGRect)bounds
 {
 return[super newCordovaViewWithFrame:bounds];
 }
 */

/* Comment out the block below to over-ride */
/*
 #pragma CDVCommandDelegate implementation
 
 - (id) getCommandInstance:(NSString*)className
 {
 return [super getCommandInstance:className];
 }
 
 - (BOOL) execute:(CDVInvokedUrlCommand*)command
 {
 return [super execute:command];
 }
 
 - (NSString*) pathForResource:(NSString*)resourcepath;
 {
 return [super pathForResource:resourcepath];
 }
 
 - (void) registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
 {
 return [super registerPlugin:plugin withClassName:className];
 }
 */



#pragma UIWebDelegate implementation

- (void) webViewDidFinishLoad:(UIWebView*) theWebView
{
    
    
    NSLog(@"webViewDidFinishLoad");
    if (firstLoad) {
        //To prevent hyperlinking numbers as phone no.
        theWebView.dataDetectorTypes=UIDataDetectorTypeNone;
        
        theWebView.scrollView.scrollEnabled = NO;
        theWebView.scrollView.bounces = NO;
        [theWebView stringByEvaluatingJavaScriptFromString:@"blockUIforVersionCheck();"];
        firstLoad=NO;
        
        //Enable automatic keyboard popup
        [theWebView setKeyboardDisplayRequiresUserAction:NO];
        // Black base color for background matches the native apps
        //theWebView.backgroundColor = [UIColor blackColor];
        theWebView.backgroundColor = UIColorFromRGB(0x6691b4);
        
        
        
    }
    else
    {
        if (isRedirect) {
            isRedirect=NO;
            isRefresh=YES;
            
        }
        else if(isRefresh){
            [theWebView stringByEvaluatingJavaScriptFromString:@"blockUIforRefresh();"];
            isRefresh=YES;
            memoryWarningCount=0;
        }
        
        
        [theWebView stringByEvaluatingJavaScriptFromString:@"$.setRefreshState(false)"];
        [theWebView stringByEvaluatingJavaScriptFromString:@"setMagnifierIframeState()"];
    }
    
    
    
    
    /*
     // only valid if ___PROJECTNAME__-Info.plist specifies a protocol to handle
     if (self.invokeString)
     {  NSLog(@"Invoke String : %@",self.invokeString);
     // this is passed before the deviceready event is fired, so you can access it in js when you receive deviceready
     NSString* jsString = [NSString stringWithFormat:@"var invokeString = \"%@\";", self.invokeString];
     [theWebView stringByEvaluatingJavaScriptFromString:jsString];
     }
     */
    
    
    return [super webViewDidFinishLoad:theWebView];
    
}


//To remove bar above keyboard

//- (void) removeBar {
//    // Locate non-UIWindow.
//    UIWindow *keyboardWindow = nil;
//    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
//        if (![[testWindow class] isEqual:[UIWindow class]]) {
//            keyboardWindow = testWindow;
//            break;
//        }
//    }
//    
//    // Locate UIWebFormView.
//    for (UIView *possibleFormView in [keyboardWindow subviews]) {
//        // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
//        if ([[possibleFormView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
//            for (UIView *subviewWhichIsPossibleFormView in [possibleFormView subviews]) {
//                if ([[subviewWhichIsPossibleFormView description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
//                    [subviewWhichIsPossibleFormView removeFromSuperview];
//                }
//            }
//        }
//    }
//}

- (void)nextTab {
    NSLog(@"TAB!!!!");
}

- (void)prevTab {
    
    NSLog(@"TAB!!!!");
}

- (void)removeBar {
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (UIView *possibleFormView in [keyboardWindow subviews]) {
        // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
        if ([[possibleFormView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
            NSLog(@"Found UIPeripheralHostView");
            //[possibleFormView removeFromSuperview];
            for (UIView *subviewWhichIsPossibleFormView in [possibleFormView subviews]) {
                NSLog(@"%@ in UIPeripheralHostView",[subviewWhichIsPossibleFormView description]);
                if ([[subviewWhichIsPossibleFormView description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
                    NSLog(@"Found UIWebFormAccessory");
                    [subviewWhichIsPossibleFormView removeFromSuperview];
                }
                else if ([[subviewWhichIsPossibleFormView description] rangeOfString:@"UIKBInputBackdropView"].location != NSNotFound) {
                    NSLog(@"Found UIKBInputBackdropView");
                    [subviewWhichIsPossibleFormView removeFromSuperview];
                }
                // iOS 6 leaves a grey border / shadow above the hidden accessory row
                if ([[subviewWhichIsPossibleFormView description] rangeOfString:@"UIImageView"].location != NSNotFound) {
                    // we need to add the QuartzCore framework for the next line
                    //NSLog(@"Found subviewWhichIsPossibleFormView");
                    //[[subviewWhichIsPossibleFormView layer] setOpacity: 0.0];
                    
                    [subviewWhichIsPossibleFormView removeFromSuperview];
                }
            }
        }
    }
}


- (void)keyboardWillShow:(NSNotification*) notification {
    // remove the bar in the next runloop (not actually created at this point)
    //[[self webView] endEditing:YES ];
    //NSLog(@"Keyboard will show");
    [self performSelector:@selector(removeBar) withObject:nil afterDelay:0];
}



- (void)keyboardWillHide:(NSNotification*) notification {
    
    //handle keyboard hding, might be useful later
}

//method to show show/hide guided acces screen on disable/enable guided access
- (void)guidedAccessChanged:(NSNotification*) notification {
    //NSLog(@"Guided Access changed!!");
    
    if(UIAccessibilityIsGuidedAccessEnabled())
    {
        [[super webView] stringByEvaluatingJavaScriptFromString:@"unblockGuidedAccess();"];
        
        
    }
    else
    {
        //If guided access is disabled hide the keyboard
        [[super webView] stringByEvaluatingJavaScriptFromString:@"blockGuidedAccess();"];
        [[self webView] endEditing:YES];
    }
    
}


- (void)screenshotTaken:(NSNotification*) notification {
    NSLog(@"Screenshot Changed");
    //[[super webView] stringByEvaluatingJavaScriptFromString:@"lz.embed.setCanvasAttribute(\"showScreenshotWarning\", true);"];
}

/* Comment out the block below to over-ride */



- (void) webViewDidStartLoad:(UIWebView*)theWebView
{
    //NSLog(@"webViewDidStartLoad");
    [theWebView stringByEvaluatingJavaScriptFromString:@"$.setRefreshState(true)"];

	return [super webViewDidStartLoad:theWebView];
}

/*
 - (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
 {
 return [super webView:theWebView didFailLoadWithError:error];
 }
 
 - (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
 {
 return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
 }
 */

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    //NSLog(@"LOADING from: %@", [[request URL] absoluteString]);
    
    return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    //NSLog(@"failed load from: %@", [error description]);
    return [super webView:theWebView didFailLoadWithError:error];
}


@end
