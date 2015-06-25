
// Created by Sabyasachi shadangi on 05/08/2012.
// Copyright 2012 sabyasachi shadangi. All rights reserved.

#import "PersistenceAction.h"
#define CLEAR_ALL_CACHE {[[NSURLCache sharedURLCache] setDiskCapacity:0];[[NSURLCache sharedURLCache] setMemoryCapacity:0]; }

//Code to bypass certificate errors : Comment these before app store deployment
/*
@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end
*/
@implementation PersistenceAction

@synthesize loginResponseXML;
@synthesize contentURI;
@synthesize tmsURL;
/**
 * Constructor of the object.
 */
- (id) init {
  if (self = [super init]) {
  }
    tmsURL=[NSString stringWithFormat:@"https://%@",[PersistenceAction getSettingString:@"tms.server.host"]];
    //NSLog(@"TMS =%@",tmsURL);
    responseData = [[NSMutableData alloc] init];
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
     //audioResponseHash  = [[NSMutableDictionary alloc] init] ;
  return self;
}


- (void)unloadCache:(NSNotification*) notification {
    //NSLog(@"Memory Warning Notification Received");
    //items=nil;
    //images=nil;
    //CLEAR_ALL_CACHE
    // Flush all cached data
    //[[NSURLCache sharedURLCache] removeAllCachedResponses];
}


+(NSString *) updateRequired
{
    
    //Current Versioncheck
    NSString *currentVersion=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    //NSLog(@"Current Version: %@",currentVersion);
    //itunes Versioncheck
    NSError *err=nil;
    NSString *ver=nil;
    NSRange range;
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    //NSLog(@"Bundle iD %@",bundleIdentifier);
    
    NSString *versionCheckURLString=[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@",bundleIdentifier];
    //NSString *versionCheckURLString=[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=com.ctb.oasin"];

     //NSString *json=[[NSString alloc]initWithContentsOfURL:[NSURL URLWithString:@"http://itunes.apple.com/lookup?bundleId=com.ctb.oasin"] encoding:NSUTF8StringEncoding error:&err];
    
    NSString *json=[[NSString alloc]initWithContentsOfURL:[NSURL URLWithString:versionCheckURLString] encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        //NSLog(@"Version Check failed with error : %@",[err description]);
        return @"N";
    }
    else {
        range=[json rangeOfString:@"\"version\":\""];
        //NSLog(@"JSON Response : %@",json);
        if (range.location==NSNotFound) {
            return @"N";
        }
         json=[json substringFromIndex:range.location+range.length];
        ////NSLog(@"JSON Response substring 1 : %@",json);
        range=[json rangeOfString:@"\""];
        ver=[json substringToIndex:range.location];
        //NSLog(@"Version : %@",ver);
        
        
    }
    
    float curVer=[currentVersion floatValue];
    float highestVer=[ver floatValue];
    
    //NSLog(@" %@", curVer<highestVer?@"Needs Update":@"Update not required");
    if (curVer<highestVer) {
        return @"Y";
    }
    else
    {
        return @"N";
    }
}

+(NSString *) getSettingString: (NSString *)key
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"OAS.plist"];
    NSMutableDictionary* plistDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:finalPath];
    NSString *value =  [plistDictionary objectForKey:key];
    return value;
}

+ (NSString *) isGuidedAccessEnabled
{
    
    //Guided Access : Uncomment This for simulator
    //return @"Y";
       
    if(UIAccessibilityIsGuidedAccessEnabled())
    {
        return @"Y";
    }
    else
    {
        return @"N";
    }
}

- (NSString *) getProductType
{
//    NSString *fileWithPath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"txt"];
//    NSString *productString = [[NSString alloc] initWithContentsOfFile:fileWithPath encoding:NSUTF8StringEncoding error:NULL];
//    NSString *productType=[productString substringFromIndex:15];
    NSString *productType=[PersistenceAction getSettingString:@"product.type"];
    NSString *result = [NSString stringWithFormat:@"<%@/>",productType];
    
    //NSLog(@"PRODUCT TYPE : %@",productType);
    return result;

}

-(void) saveTimer:(NSTimer*) timer
{
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath=[cachePath stringByAppendingPathComponent:@"time.save"];
    //NSLog(@"timer*******%f",CFAbsoluteTimeGetCurrent());
    [[NSString stringWithFormat:@"%f",CFAbsoluteTimeGetCurrent()]  writeToFile:cachePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}


- (NSString *) writeToAuditFile:(NSString *)xml
{
    return @"<OK />";
}

- (NSString *) uploadAuditFile:(NSString *)xml
{
    return @"<OK />";
}

- (NSString *) login:(NSString *)xmlString{
    NSString *postString = [NSString stringWithFormat:@"requestXML=%@",xmlString];
    
    //NSLog(@"post String: %@",postString);
    
    LoginResponseParser *lResponseParser=[[LoginResponseParser alloc] initWithData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [lResponseParser setElement:@"login_request"];
    [lResponseParser parse];
    //NSLog(@"Status %@",lResponseParser.trackerinfo);
    NSString *userName =[lResponseParser getAtrtributeValue:@"user_name"];
    NSString *password =[lResponseParser getAtrtributeValue:@"password"];
    NSString *accessCode =[lResponseParser getAtrtributeValue:@"access_code"];
    
    [UtilityAction saveUser:userName Password:password AccessCode:accessCode];

    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/TestDeliveryWeb/CTB/login.do",tmsURL]];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"%@/TestDeliveryWeb/CTB/login.do",tmsURL]);
    
    //Local URL    
    //NSURL *url = [NSURL URLWithString:@"http://192.168.14.46:9090/TestDeliveryWeb/CTB/login.do"];
    
    
    // QA URL
    //NSURL *url = [NSURL URLWithString:@"https://10.201.226.129:443/TestDeliveryWeb/CTB/login.do"];
    
    //Staging URL
    //NSURL *url = [NSURL URLWithString:@"https://tms-oas-staging.ctb.com/TestDeliveryWeb/CTB/login.do"];
   
    //WV Prod URL
    //NSURL *url = [NSURL URLWithString:@"https://oasdelivery.ctb.com/TestDeliveryWeb/CTB/login.do"];
    
    //ISTEP Prod URL
    //NSURL *url = [NSURL URLWithString:@"https://istep-oas.ctb.com/TestDeliveryWeb/CTB/login.do"];
    
    //CQA URL
    //NSURL *url = [NSURL URLWithString:@"https://oascqa-ewdc.ctb.com/TestDeliveryWeb/CTB/login.do"];
    
    NSData *xmlResponseData;

    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    //Code to bypass certificate errors : Comment these before app store deployment
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    NSString *msgLength = [NSString stringWithFormat:@"%d",[postString length]];
    [req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error=nil;
    
    NSURLResponse *resp=[[NSURLResponse alloc] init];
    
    xmlResponseData=[NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
    if (error) {
        return @"<ERROR><HEADER></HEADER><MESSAGE>Connection to Server Lost, Unable to Login</MESSAGE><CODE>556</CODE></ERROR>";
    }
    NSString *xmlResponseString=[[NSString alloc] initWithData:xmlResponseData encoding:NSUTF8StringEncoding];
    
    
    
    if(!error)
      {
        printf("Connnection Established...");
          
          //NSLog(@"##############  Received data #################\n %@",xmlResponseString);
          LoginResponseParser *lResponseParser=[[LoginResponseParser alloc] initWithData:[xmlResponseString dataUsingEncoding:NSUTF8StringEncoding]];
          
          [lResponseParser setElement:@"status"];
          [lResponseParser parse];
          //NSLog(@"Status %@",lResponseParser.trackerinfo);
          NSString *statusCode =[lResponseParser getAtrtributeValue:@"status_code"];
          //NSLog(@"Status code : %@",statusCode);
          if ([statusCode isEqualToString:@"200"]) {
              ResponseParser *rp=[[ResponseParser alloc] initWithData:xmlResponseData];
              [rp setElement:@"sco"];
              [rp parse];
              contentURI=[rp getAtrtributeValue:@"contentURI"];
              [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(saveTimer:) userInfo:nil repeats:YES];
              
          }
        }
    else{
        //NSLog(@"Error in Synchronous Connection : %@",[error description]);
        }
    return xmlResponseString;
      }

- (NSString *) save:(NSString *)xmlString
{
    //[TestSecurityUtils updatePhotoCount];
    //NSLog(@"Inside class PersistenceAction, save method called: %@",xmlString);
    
    //for uploading Recorded Audio as Base64
  /*  if ([xmlString rangeOfString:recordedFileName]) {
   
    //Convert to Base64String
    xmlString=[xmlString stringByReplacingOccurrencesOfString:recordedFileName withString:base64Audio]
    
    }
   */
    NSString *postStringSave = [NSString stringWithFormat:@"requestXML=%@",xmlString];
    
    
    // //NSLog(@"post String for save: %@",postStringSave);
    
    
    NSURL *urlSave=[NSURL URLWithString:[NSString stringWithFormat:@"%@/TestDeliveryWeb/CTB/save.do",tmsURL]];
    // QA URL
    //NSURL *urlSave = [NSURL URLWithString:@"https://10.201.226.129:443/TestDeliveryWeb/CTB/save.do"];
    
    
    //Local URL
     //NSURL *urlSave = [NSURL URLWithString:@"http://192.168.14.46:9090/TestDeliveryWeb/CTB/save.do"];
    
    
    //Staging URL
    // NSURL *urlSave = [NSURL URLWithString:@"https://tms-oas-staging.ctb.com/TestDeliveryWeb/CTB/save.do"];
    
    //CQA URL
    //NSURL *urlSave = [NSURL URLWithString:@"https://oascqa-ewdc.ctb.com/TestDeliveryWeb/CTB/save.do"];
    
    
    //ISTEP PROD URL
    //NSURL *urlSave = [NSURL URLWithString:@"https://istep-oas.ctb.com/TestDeliveryWeb/CTB/save.do"];
    
    //WV PROD URL
    //NSURL *urlSave = [NSURL URLWithString:@"https://oasdelivery.ctb.com/TestDeliveryWeb/CTB/save.do"];
    postStringSave=[postStringSave stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *xmlResponseDataSave;
    NSMutableURLRequest *reqSave = [[NSMutableURLRequest alloc] initWithURL:urlSave];
    //CODE TO bypass invalid certificate :
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[urlSave host]];
    NSString *msgLengthSave = [NSString stringWithFormat:@"%d",[postStringSave length]];
    [reqSave addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[reqSave addValue:@"text/x-json" forHTTPHeaderField:@"Content-Type"];
    
    [reqSave addValue:msgLengthSave forHTTPHeaderField:@"Content-Length"];
    [reqSave setHTTPMethod:@"POST"];
    NSData *saveData=[postStringSave dataUsingEncoding:NSUTF8StringEncoding];
    [reqSave setHTTPBody:saveData];
    
    NSError *error=nil;
    
    NSURLResponse *respSave=[[NSURLResponse alloc] init];
    
    xmlResponseDataSave=[NSURLConnection sendSynchronousRequest:reqSave returningResponse:&respSave error:&error];
    NSString *xmlResponseStringSave=[[NSString alloc] initWithData:xmlResponseDataSave encoding:NSUTF8StringEncoding];
    
    //NSLog(@"Save Response %@",xmlResponseStringSave);
    
    
    if (xmlResponseDataSave.length==0 || xmlResponseDataSave==nil) {
        return @"<ERROR><HEADER></HEADER><MESSAGE>Connection to Server Lost, Unable to Save</MESSAGE><CODE>556</CODE></ERROR>";
    }
     
    
    /*
    if (xmlResponseStringSave.length==0 || xmlResponseStringSave==@"" || xmlResponseStringSave==nil ) {
        return @"<ERROR><HEADER></HEADER><MESSAGE>Connection to Server Lost, Unable to Save</MESSAGE><CODE>556</CODE></ERROR>";
    }
    */
    //Check if lev is lms_finish i.e. check if there is another subtest after this or not
    if ([xmlString rangeOfString:@"<lev e=\"lms_finish\"/>"].location==NSNotFound) {
        if([xmlResponseStringSave rangeOfString:@"<error" options:NSCaseInsensitiveSearch].location == NSNotFound) {
            xmlResponseStringSave = @"<OK />";  //If there is no subtest return ok
        } else {
            xmlResponseStringSave = @"<ERROR><HEADER></HEADER><MESSAGE>Error in TMS</MESSAGE><CODE>556</CODE></ERROR>";
        }
    }/*
      else
    {
        xmlResponseStringSave=[[NSString alloc]initWithData:xmlResponseDataSave encoding:NSUTF8StringEncoding];
    }
    */
   
    
    return xmlResponseStringSave;
    
}



- (NSString *) feedback:(NSDictionary *)xmlString{
    //NSLog(@"Inside class PersistenceAction, Feedback method called with xml: %@",xmlString);
   
    NSURL *urlFeedback=[NSURL URLWithString:[NSString stringWithFormat:@"%@/TestDeliveryWeb/CTB/feedback.do",tmsURL]];
    
    // QA URL
    //NSURL *urlFeedback = [NSURL URLWithString:@"https://10.201.226.129:443/TestDeliveryWeb/CTB/feedback.do"];
    
    
    //Local URL
    // NSURL *urlFeedback = [NSURL URLWithString:@"http://192.168.14.46:9090/TestDeliveryWeb/CTB/feedback.do"];
    
    
    //Staging URL
    // NSURL *urlFeedback = [NSURL URLWithString:@"https://tms-oas-staging.ctb.com/TestDeliveryWeb/CTB/feedback.do"];
    
    //WV PROD URL
    //NSURL *urlFeedback = [NSURL URLWithString:@"https://oasdelivery.ctb.com/TestDeliveryWeb/CTB/feedback.do"];
    
    //ISTEP PROD URL
    //NSURL *urlFeedback = [NSURL URLWithString:@"https://istep-oas.ctb.com/TestDeliveryWeb/CTB/feedback.do"];
    
    
    //CQA URL
    //NSURL *urlFeedback = [NSURL URLWithString:@"https://oascqa-ewdc.ctb.com/TestDeliveryWeb/CTB/feedback.do"];
    
    NSData *xmlResponseDataFeedback;
    
    
    NSMutableURLRequest *reqFeedback = [[NSMutableURLRequest alloc] initWithURL:urlFeedback];
    //CODE TO bypass invalid certificate :
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[urlSave host]];
   
    [reqFeedback addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
   
    [reqFeedback setHTTPMethod:@"POST"];
   
    NSError *error=nil;
    
    NSURLResponse *respFeedback=[[NSURLResponse alloc] init];
    
    xmlResponseDataFeedback=[NSURLConnection sendSynchronousRequest:reqFeedback returningResponse:&respFeedback error:&error];
    NSString *xmlResponseStringFeedback=[[NSString alloc] initWithData:xmlResponseDataFeedback encoding:NSUTF8StringEncoding];
    
    if (!error) {
        //NSLog(@"FeedBack Response : %@",xmlResponseStringFeedback);
        
    }
    else{
        //NSLog(@"Error in Feedback : %@",[error description]);
        return @"<ERROR><HEADER></HEADER><MESSAGE>Connection to Server Lost, Unable to submit feedback</MESSAGE><CODE>556</CODE></ERROR>";
    }
    
    
    return xmlResponseStringFeedback;
    
    
}

@end
