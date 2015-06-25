			//
//  ContentAction.m
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 10/5/12.
//  Copyright (c) 2012 mcgrawhill ctb. All rights reserved.
//  Prod workspace

#import "ContentAction.h"


#define CLEAR_ALL_CACHE {[[NSURLCache sharedURLCache] setDiskCapacity:0];[[NSURLCache sharedURLCache] setMemoryCapacity:0]; }

//CODE TO bypass invalid certificate :
//@interface NSURLRequest (DummyInterface)
//+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
//+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
//@end


@implementation ContentAction


//@synthesize parser;
//@synthesize itemData;
//@synthesize fileParts;
//@synthesize fileUrl;
//@synthesize fileData; //Moved to downloadContentFromURL
//@synthesize extractedfilesfolder;
//@synthesize images;
//@synthesize subtests;
//@synthesize items;
@synthesize contentURI;
@synthesize musicPlayer;
@synthesize musicPath;
@synthesize teItemsPath;


- (id) init {
    if (self = [super init]) {
    }
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadCache:) name:@"ReceivedMemoryWarningNotification" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    return self;
}

- (void)unloadCache:(NSNotification*) notification {
    //NSLog(@"Memory Warning Notification Received");
    //items=nil;
    //images=nil;
   // [items removeAllObjects];
   // [images removeAllObjects];
    //Flush all cached data
    //[[NSURLCache sharedURLCache] removeAllCachedResponses];
    //CLEAR_ALL_CACHE
}


- (NSString *) getSubtest:(NSString *)xml{
    ResponseParser *rp = [[ResponseParser alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [rp setElement:@"get_subtest"];
    [rp parse];
    NSString *subtestId=[rp getAtrtributeValue:@"subtestid"];
    NSString *hash=[rp getAtrtributeValue:@"hash"];
    NSString *key=[rp getAtrtributeValue:@"key"];
    
    NSString *xmlResponseString=nil;
    
    //Create Dictionary to store subtests XML, if not present
    if (!subtests) {
        subtests=[[NSMutableDictionary alloc]init];
    }
    else{
    //Check if required subtest is present in subtests dictionary
    xmlResponseString=[subtests objectForKey:subtestId];
    }
    
    if (!xmlResponseString) {
        //Subtest is not present in dictionary
        //Check in prepositioned content
        
        //Get path for subtests file in object bank
        NSString* path = [[NSBundle mainBundle] pathForResource:subtestId ofType:@"eam" inDirectory:@"Object Bank"];
        //if file is present:
        //Check for path
        if(!path)
        {
            //Download Content if not present
            NSLog(@"Path for prepositioned content not found");
            xmlResponseString=[self downloadSubTest:subtestId From:contentURI withHash:hash andKey:key];
        }
        else
        {
            //Decrypt content if present
            xmlResponseString = [self decryptFile:path WithHash:hash WithKey:key];
            //check decrypted contents
            if (!xmlResponseString) {
                //download contents if decryption failed
                //NSLog(@"Decryption Failed. Downloading Content");
                xmlResponseString=[self downloadSubTest:subtestId From:contentURI withHash:hash andKey:key];
                
            }
        }
         
        
        
        /*
         if (xmlResponseString) {
            //NSLog(@"Getting subtest %@ from %@",subtestId,path);
            //Decrypt the file at path
            
        }
        else
        {   //NSLog(@"Error : %@",error.description);
            xmlResponseString=[self downloadSubTest:subtestId From:contentURI withHash:hash andKey:key];
        }
         */
       
         //Put the subtest in the subtests dictionary
         [subtests setObject:xmlResponseString forKey:subtestId];
   }
    //NSLog(@"Subtests : %@", subtests);
    
    return xmlResponseString;
}


-(NSString *) downloadSubTest:(NSString * ) subTestId From:(NSString *) URL withHash: (NSString *) hash andKey: (NSString *) key
{//NSLog(@"Inside downloadSubtest");
    NSString *trackerURL=[[[[URL stringByAppendingString:subTestId] stringByAppendingString:@"$"]stringByAppendingString:hash] stringByAppendingString:@".xml"];
     NSLog(@"Downloading URL: %@",trackerURL);
    
    if ( ![self downloadContentFromURL:trackerURL]) {
        return @"<ERROR><HEADER></HEADER><MESSAGE>Connection to Server Lost</MESSAGE><CODE>556</CODE></ERROR>";
    }
    
    NSString *fileWithPath=[[extractedfilesfolder stringByAppendingString:subTestId] stringByAppendingString:@".eam"];
    //NSLog(@"EAM file path: %@",fileWithPath);
    
    NSString *xmlResponse = [self decryptFile:fileWithPath WithHash:hash WithKey:key];
    return xmlResponse;
    
}



- (NSString *) downloadItem:(NSString *)xml
{
    ResponseParser *rp=[[ResponseParser alloc] initWithString:xml];
    [rp setElement:@"download_item"];
    [rp parse];
    NSString *itemid=[rp getAtrtributeValue:@"itemid"];
    NSString *hash=[rp getAtrtributeValue:@"hash"];
    NSString *key=[rp getAtrtributeValue:@"key"];
    
    NSString* file = [[NSBundle mainBundle] pathForResource:itemid ofType:@"ecp" inDirectory:@"Object Bank"];
    

    NSString *decryptedContent=nil;
    
    if(!file)
    {
        file=[[extractedfilesfolder stringByAppendingString:itemid] stringByAppendingString:@".ecp"];
        
    }
    decryptedContent=[self decryptFile:file WithHash:hash WithKey:key];
    
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    itemCache =[NSString stringWithFormat:@"%@/itemCache", [paths objectAtIndex:0]] ;
    NSLog(@"itemCache directory : %@",itemCache);
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir;
    //NSLog(@"ItemCache %@",[fileManager fileExistsAtPath:itemCache isDirectory:&isDir]?@"exists":@"does not exist");
    if(![fileManager fileExistsAtPath:itemCache isDirectory:&isDir])
    {
        NSLog(@"itemCache does not exist");
        if(![fileManager createDirectoryAtPath:itemCache withIntermediateDirectories:YES attributes:nil error:NULL])
        {
            NSLog(@"Error:failed to create folder  %@", itemCache);
        }
    }
    NSString *decryptedContentpath=[NSString stringWithFormat:@"%@/%@.ecp",itemCache,itemid];
    [decryptedContent writeToFile:decryptedContentpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
     */
    [self processContent:decryptedContent];
    [self getItemFromContent:decryptedContent withItemId:itemid];
    
    return @"<OK />";
}


- (NSString *) downloadFileparts:(NSString *)xmlString{
    return @"<FILE_PART_OK />";
}

- (NSString *) getItem:(NSString *)xml
{
    ResponseParser *rp = [[ResponseParser alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [rp setElement:@"get_item"];
    [rp parse];
    
    NSString *itemid=[rp getAtrtributeValue:@"itemid"];
    
    NSString *hash=[rp getAtrtributeValue:@"hash"];
    NSString *key=[rp getAtrtributeValue:@"key"];
    //NSString *result =[self getItem:itemid withHash:hash WithKey:key];
   
    NSString *result =[self getItembyId:itemid];
    if (!result || [result isEqualToString:@""]) {
        NSLog(@"Item %@ not found in decrypted items dictionary",itemid);
     result =[self getItem:itemid withHash:hash WithKey:key];
    }
    //NSLog(@"========Item=======\n%@",result);
    return result;
}

- (NSString *) getImage:(NSString *)xml
{
    ResponseParser *rp = [[ResponseParser alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [rp setElement:@"get_image"];
    [rp parse];
    
    
    NSString *imageInfo=[rp getAtrtributeValue:@"imageid"];
    // //NSLog(@"Image Info: %@",imageInfo);
    NSArray *imageInfoArray=[imageInfo componentsSeparatedByString:@"||"];
    NSString *imageId_prefix=[imageInfoArray objectAtIndex:0];
    NSString *imageId=[imageInfoArray objectAtIndex:1];
    NSString *result =[self getImagebyId:imageId];
    //NSLog(@"Image ID %@",imageId);
    result=[NSString stringWithFormat:@"%@||%@",imageId_prefix,result];
   
 //   //NSLog(@"**********Image**********\n %@",result);
    return result;
}


-(NSString *) getImagebyId:(NSString *) imageId;
{
 //   //NSLog(@"Images size %u", [images count]);
    return [images objectForKey:imageId];
}



-(NSString *) getItem:(NSString *) itemId withHash:(NSString *) hash WithKey:(NSString *)key
{
    //NSLog(@"Getting item: %@",itemId);
    NSString *itemXML;
   // NSString *itemXML= [self getItembyId:itemId];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    extractedfilesfolder = [paths objectAtIndex:0];
    ////NSLog(@"Extracted files folder : %@",extractedfilesfolder);
    //NSString* file=[[@"/" stringByAppendingString:itemId ] stringByAppendingString:@".ecp"];
    //NSString *pathWithFile =[extractedfilesfolder stringByAppendingPathComponent:[itemId stringByAppendingPathExtension:@"ecp"]];
    
    ////NSLog(@"Path with file : %@",pathWithFile);
    
   /*
    NSString* file = [[NSBundle mainBundle] pathForResource:itemId ofType:@"ecp" inDirectory:@"Object Bank"];
    NSData *filedata=[[NSData alloc] initWithContentsOfFile:file];
    if (filedata.length!=0) {
        file=[[@"/" stringByAppendingString:itemId ] stringByAppendingString:@".ecp"];
        
        
    }*/
    
    NSString *file = [[NSBundle mainBundle] pathForResource:itemId ofType:@"ecp" inDirectory:@"Object Bank"];
    
    
    NSString *decryptedContent=nil;
    
    if(!file)
    {
        file=[[extractedfilesfolder stringByAppendingString:itemId] stringByAppendingString:@".ecp"];
        
    }
    decryptedContent=[self decryptFile:file WithHash:hash WithKey:key];
    [self processContent:decryptedContent];
    [self getItemFromContent:decryptedContent withItemId:itemId];
    
/*    NSString *decryptedContent=[self decryptFile:[extractedfilesfolder stringByAppendingString:file]WithHash:hash WithKey:key];
    
    if ([decryptedContent isEqualToString:@""]) {
        //NSLog(@"Content not found at %@",extractedfilesfolder);
    }
 */
    //decryptedContent=[self decryptFile:file WithHash:hash WithKey:key];
    //NSLog(@"File Decrypted : %@",decryptedContent);
    
    [self processContent:decryptedContent];
  //  //NSLog(@"Image extracted from content and put in dictionary");
   // //NSLog(@"Dictionary : %@",images);
    [self getItemFromContent:decryptedContent withItemId:itemId];
    itemXML= [self getItembyId:itemId];
    
    return itemXML;
}



-(NSString *) decryptFile:(NSString *) filePath WithHash:(NSString *) hash WithKey:(NSString *)key{
    @try{
        NSError *error=nil;
       // //NSLog(@"Decrypting %@",filePath);
        NSData* content = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
     //   //NSLog(@"Input length: %u",content.length);
        if (error) {
            //NSLog(@"%@",[error description]);
        }
        
        CC_MD5_CTX md5data;
        CC_MD5_Init(&md5data);
        CC_MD5_Update(&md5data, [content bytes], [content length]);
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &md5data);
        NSString* hashFromEncryptedFile = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7], digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]];
        NSString *recoveredHash = [hashFromEncryptedFile uppercaseString];
        ////NSLog(@"%@",recoveredHash);
        if ( hash != nil || [recoveredHash isEqualToString:hash]) {////NSLog(@"Encryption begins");
            
            CC_MD5_CTX md51;
            CC_MD5_Init(&md51);
            NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:[key length]];
            CC_MD5_Update(&md51,[keyData bytes] , [key length]);
            unsigned char generatedKey[CC_MD5_DIGEST_LENGTH];
            CC_MD5_Final(generatedKey, &md51);
            
           // NSString* dehashedKey = [NSString stringWithFormat: @"%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c", generatedKey[0], generatedKey[1], generatedKey[2], generatedKey[3], generatedKey[4], generatedKey[5], generatedKey[6], generatedKey[7], generatedKey[8], generatedKey[9], generatedKey[10], generatedKey[11], generatedKey[12], generatedKey[13], generatedKey[14], generatedKey[15]];
            
            ////NSLog(@"Dehashed Key: %@",dehashedKey);
            
            const void *vplainText;
            size_t plainTextBufferSize;
            plainTextBufferSize = [content length];
            vplainText = [content bytes];
            CCCryptorStatus ccStatus,cryptorStatus;
            uint8_t *bufferPtr = NULL;
            size_t bufferPtrSize = 0;
            size_t movedBytes = 0;
            
            bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
            bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
            memset((void *)bufferPtr, 0x0, bufferPtrSize);
            
            const void *vkey = (const void *) generatedKey;
            
            struct _CCCryptor *refer = nil;
            
            cryptorStatus = CCCryptorCreate(kCCDecrypt, kCCAlgorithmRC4, 0, vkey , CC_MD5_DIGEST_LENGTH, NULL, &refer);
            /*
            if (cryptorStatus == kCCSuccess) //NSLog(@"Cryptor SUCCESS");
            else if (cryptorStatus == kCCParamError) //NSLog(@"Cryptor PARAM ERROR");
            else if (cryptorStatus == kCCMemoryFailure) //NSLog(@"Cryptor MEMORY FAILURE");
            */
            ccStatus = CCCryptorUpdate(refer,vplainText, plainTextBufferSize, (void *)bufferPtr, bufferPtrSize, &movedBytes);
            /*
            if (ccStatus == kCCSuccess) //NSLog(@"SUCCESS");
            else if (ccStatus == kCCParamError) //NSLog(@"PARAM ERROR");
            else if (ccStatus == kCCBufferTooSmall) //NSLog(@"BUFFER TOO SMALL");
            else if (ccStatus == kCCMemoryFailure) //NSLog(@"MEMORY FAILURE");
            else if (ccStatus == kCCAlignmentError) //NSLog(@"ALIGNMENT");
            else if (ccStatus == kCCDecodeError) //NSLog(@"DECODE ERROR");
            else if (ccStatus == kCCUnimplemented) //NSLog(@"UNIMPLEMENTED");
            */
            NSData *textout = [NSData dataWithBytes:bufferPtr length:(NSUInteger)movedBytes];
            NSString *result = [[ NSString alloc ] initWithData: textout encoding:NSUTF8StringEncoding];
            ////NSLog(@"res size: %d",textout.length);
            
            //[result writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            error = nil;
            return  result;
            if (error) {
                ////NSLog(@"%@",[error description]);
                
            }
       //     //NSLog(@"Buffer Size = %lu",plainTextBufferSize);
       //     //NSLog(@"Moved bytes = %lu",movedBytes);
            
        }
        else{
            ////NSLog(@"Hash mismatch");
        }
        
    }
    @catch(NSException *exception){
        ////NSLog(@"Exception :%@",[exception reason]);
    }
}


-(void) processContent:(NSString *) content
{
    ////NSLog(@"Item with Image : %@",content);
    NSData *xmlData=[content dataUsingEncoding:NSUTF8StringEncoding];
    NSData *teItemZipData;
    NSString *teItemZipString;
    
    
    ContentXMLParserDelegate *imageParser=[[ContentXMLParserDelegate alloc] initWithData:xmlData];
    
    //parse xml
    [imageParser parse];
    
    ////NSLog(@"Image data value after parsing : %@", imageParser.imageData);
    if (images==nil) {
        images = [[NSMutableDictionary alloc] init];
    }
    
    //Add the image data obtained from parsing to images dictionary
    [images addEntriesFromDictionary:imageParser.imageData] ;
    
    
    //Get the zip data in item xml
    teItemZipString=imageParser.zipData;
    
    
    //check if there was TE item in zip data
    if (teItemZipString&&[teItemZipString length]!=0) {
        teItemZipData=[ContentAction base64DataFromString:teItemZipString];
        
        //Check if there is already  a directory named items under documents ?
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"items"];
        
        NSFileManager *fileManager= [NSFileManager defaultManager];
        BOOL isDir =YES;
        //If it's not there, Create it
        if (![fileManager fileExistsAtPath:documentsDirectory isDirectory:&isDir]) {
            [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
        }
        NSError *error;
        
        //Save the File
        NSString *zipFilePath=[documentsDirectory stringByAppendingPathComponent:@"item.zip"];
        [teItemZipData writeToFile:zipFilePath atomically:YES];
        //NSLog(@"Writing TE items zip file to %@",zipFilePath);
        
        //extract zip files
        ZipArchive *za = [[ZipArchive alloc] init];
        [za UnzipOpenFile:zipFilePath];
        
        //extract files to location specified
        BOOL chk=[za UnzipFileTo:documentsDirectory overWrite:YES];
        
        //Checking if unzip was succesfull
        if (chk) {
            teItemsPath=documentsDirectory;
            //NSLog(@"Unzipped succesfully to %@", documentsDirectory);
            
            //close the zip file
            [za UnzipCloseFile];
            
            //delete the zip file
            [fileManager removeItemAtPath:zipFilePath error:&error];
            ////NSLog(@"removed zip file : %@",zipFilePath);
            if (error) {
                ////NSLog(@"Error while deleting zip file %@",[error description]);
            }
        }
        else
        {
            //NSLog(@"Unzip failed ");
            [za UnzipCloseFile];
        }
        

    }
  //  //NSLog(@"Image data value after parsing : %@", images);
    
}


-(void) getItemFromContent:(NSString *) fileContent withItemId: (NSString *) itemID
{
    ////NSLog(@"Getting item from Content");
    //items = [[NSMutableDictionary alloc] init];
    if (items==nil) {
        items = [[NSMutableDictionary alloc] init];
    }
    
    
    //NSMutableArray *itemFiles=(NSMutableArray *) [[NSFileManager defaultManager] contentsOfDirectoryAtPath:itemFolder error:nil];
    
    //for(int index=0;index<itemFiles.count;index++)
    //{
    //contentFileName = [itemFolder stringByAppendingPathComponent:[itemFiles objectAtIndex:index]];
    // fileContent =[[NSString alloc]  initWithContentsOfFile:content encoding:NSUTF8StringEncoding error:&error];
    // //NSLog(@"The Content of file %d is %@",index,fileContent);
    
    
    //NSString *string = @\"<div>iPhone SDK Development Forums</div>\";
    NSString *result = nil;
    
    // Determine \"<asset>\" location
    NSRange assetRange = [fileContent rangeOfString:@"</item_model>" options:NSCaseInsensitiveSearch];
    // //NSLog(@"Asset range : %@",assetRange);
    if (assetRange.location != NSNotFound)
    {
        //   //NSLog(@"Asset range : %@",assetRange);
        
        // Determine \"</asset>\" location according to \"<asset>\" location
        NSRange endassetRange;
        
        endassetRange.location = assetRange.length + assetRange.location;
        endassetRange.length   = [fileContent length] - endassetRange.location;
        endassetRange = [fileContent rangeOfString:@"</element_package>" options:NSCaseInsensitiveSearch range:endassetRange];
        
        if (endassetRange.location != NSNotFound)
        {
            // Tags found: retrieve string between them
            assetRange.location += assetRange.length;
            assetRange.length = endassetRange.location - assetRange.location;
            
            result = [fileContent substringWithRange:assetRange];
        }
    }
    ////NSLog(@"This should be removed: %@", result);
    NSString *contentWithoutImage = [fileContent stringByReplacingOccurrencesOfString:result withString:@""];
    ////NSLog(@"Content With out Image of %@ : %@",[itemFiles objectAtIndex:index],contentWithoutImage);
    if ([contentWithoutImage length] != 0) {
        
        [items setObject:contentWithoutImage forKey:itemID];
        
    }
}

-(NSString *) getItembyId:(NSString *)itemId
{
    NSString *itemXML=[items objectForKey:itemId];
    if (itemXML)
    {
        itemXML=[ContentAction doUTF8Chars:itemXML];
    }
    /*else
    {
        NSString *temp=[NSString stringWithFormat:@"%@/%@.ecp",itemCache,itemId];
        NSLog(@"Getting item xml %@",temp);
        itemXML=[NSString stringWithContentsOfFile:temp encoding:NSUTF8StringEncoding error:nil];
        
        [self processContent:itemXML];
        [self getItemFromContent:itemXML withItemId:itemId];
         itemXML=[items objectForKey:itemId];
        
        itemXML=[ContentAction doUTF8Chars:itemXML];
    }*/
    return itemXML;
   
}


-(BOOL) downloadContentFromURL: (NSString *) trackerURL
{
    
    NSError *error=nil;
    NSString *urlWithoutFileName;
    NSString *fullFileName;
    NSString *filename;
    BOOL downloadSuccessful=FALSE;
    urlWithoutFileName=[trackerURL stringByDeletingLastPathComponent];
    ////NSLog(@"urlWithOutFileName : %@",urlWithoutFileName);
   // //NSLog(@"*****In downloadContentFromURL*****");
    ////NSLog(@"Downloading tracker from %@",trackerURL);
    
    NSURL *url = [NSURL URLWithString:trackerURL];
    
    //Code to bypass invalid certificate
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    // initiiate parser with url
    parser=[[NSXMLParser alloc] initWithContentsOfURL:url ];
    
    //NSString *xmlTest=[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    //NSLog(@"#######Tracker######");
    //NSLog(@"%@",xmlTest);
    
    if (error) {
        return downloadSuccessful;
    }
    
    
    parser.delegate =self ;
    
    //parse xml
    [parser parse];
    
    ////NSLog(@"Item data value after parsing : %@", self->itemData);
    
    NSMutableData *fileData = [[NSMutableData alloc] init];
    
    //for loop to download and merge file parts
    for (int index=0; index<[fileParts count]; index++) {
        fullFileName= [fileParts objectAtIndex:index];
       // //NSLog(@"Full file name: %@",fullFileName);
        fullFileName = [[urlWithoutFileName stringByAppendingString:@"/"] stringByAppendingString:fullFileName];
        [fileParts replaceObjectAtIndex:index withObject:fullFileName];
        ////NSLog(@"File part %d : %@", index+1, [fileParts objectAtIndex:index]);
        //initialize the url of the file
       fileUrl = [NSURL URLWithString:[fileParts objectAtIndex:index]];
        ////NSLog(@"File URL : %@",fileUrl);
        //fileUrl = [NSURL fileURLWithPath:[fileParts objectAtIndex:index]];
        //get data from the file url and initialize the urldata with it
        NSData *urlData = [NSData dataWithContentsOfURL:fileUrl];
         if (urlData.length==0) {
            return downloadSuccessful;
        }
        else
        {
            NSLog(@"File part %d  size: %d", index+1, [urlData length]);
            
        }
        
        [fileData appendData:urlData];
        
        urlData =nil;
    }
    ////NSLog(@"The saved file size is :%d",[fileData length]);
    
    
    filename=[[trackerURL stringByDeletingPathExtension]lastPathComponent];
    
    //Look for available locations for saving the data
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *zipPath = [[path stringByAppendingPathComponent:filename] stringByAppendingString:@".zip"];
    
    //set extraction location
    // NSString *unzipPath=[[zipPath stringByDeletingPathExtension] stringByAppendingString:@"/"];
    NSString *unzipPath =[path stringByAppendingString:@"/"];
    ////NSLog(@"The file path is: %@",path);
    
    // Saving data into a Zip file
    [fileData writeToFile:zipPath atomically:YES];
    
    ////NSLog(@"The save file size: %d", [fileData length]);
    
    // Unzipping the zipped file.
    ZipArchive *za = [[ZipArchive alloc] init];
    [za UnzipOpenFile:zipPath];
    
    //extract files to location specified
    BOOL chk=[za UnzipFileTo:unzipPath overWrite:YES];
    
    //Checking if unzip was succesfull
    if (chk) {
        extractedfilesfolder=unzipPath;
        ////NSLog(@"Unzipped succesfully to %@", unzipPath);
        
        //close the zip file
        [za UnzipCloseFile];
        
        //delete the zip file
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:&error];
        ////NSLog(@"removed zip file : %@",zipPath);
        if (error) {
            ////NSLog(@"Error while deleting zip file %@",[error description]);
        }
    }
    else
    {
        ////NSLog(@"Unzip failed ");
        [za UnzipCloseFile];
        return downloadSuccessful;
    }
    
    downloadSuccessful=TRUE;
    return downloadSuccessful;
}

+(void) deleteCache;
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
            ////NSLog(@"Error while deleting %@",[path stringByAppendingPathComponent:file]);
        }
    }
    //NSString *zipPath = [[path stringByAppendingPathComponent:filename] stringByAppendingString:@".zip"];
    
}

+(NSString *) doUTF8Chars:(NSString *) input{
 int lineFeed = 10;
 int carriageReturn = 13;
 int tab = 9;
 int plusSign = 43;
 int maxASCII = 127;
 int space = 127;
    
    NSString *retval=@"";
    bool isPreviousCharSpace = true;
 //   //NSLog(@"Do UTF8 Chars");
    for(int i = 0; i < [input length]; i++)
    {
        //char c = input.charAt( i );
        //unichar c = [input characterAtIndex:i];
        
        //int intc=c;
        int intc=[input characterAtIndex:i];
        
        if( intc != tab && intc != lineFeed && intc !=carriageReturn )
        {
            if( intc <= maxASCII && intc != plusSign )
            {
                if( intc == space )
                {
                    if( !isPreviousCharSpace )
                    {   NSString *temp=[NSString stringWithFormat:@"%c",intc];
                        retval=[retval stringByAppendingString:temp];
                        //retval.append( c );
                        isPreviousCharSpace = true;
                    }
                }
                else
                {
                    isPreviousCharSpace = false;
                    //retVal.append( c );
                    NSString *temp=[NSString stringWithFormat:@"%c",intc];
                    retval=[retval stringByAppendingString:temp];
                    
                }
            }
            else
            {
               // NSString *temp=@"&#";
                
                isPreviousCharSpace = false;
                //c=intc;
                retval=[retval stringByAppendingString:[NSString stringWithFormat:@"&#%d;",intc]];
               // retval.append( "&#" ).append( intc ).append( ';' );
                
            }
        }
    }
    
    
    retval=[retval stringByReplacingOccurrencesOfString:@"&#+;" withString:@"&#x002B;"];
    retval=[retval stringByReplacingOccurrencesOfString:@"+" withString:@"&#x002B;"];
    
    retval=[retval stringByReplacingOccurrencesOfString:@"&#x003C" withString:@"&LT;"];
    //retval=[retval stringByReplacingOccurrencesOfString:@"<" withString:@"&LT;"];
    
    return retval;
    
}

+ (NSData *)base64DataFromString: (NSString *)string
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil)
    {
        return [NSData data];
    }
    
    ixtext = 0;
    
    tempcstring = (const unsigned char *)[string UTF8String];
    
    lentext = [string length];
    
    theData = [NSMutableData dataWithCapacity: lentext];
    
    ixinbuf = 0;
    
    while (true)
    {
        if (ixtext >= lentext)
        {
            break;
        }
        
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z'))
        {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z'))
        {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9'))
        {
            ch = ch - '0' + 52;
        }
        else if (ch == '+')
        {
            ch = 62;
        }
        else if (ch == '=')
        {
            flendtext = true;
        }
        else if (ch == '/')
        {
            ch = 63;
        }
        else
        {
            flignore = true;
        }
        
        if (!flignore)
        {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext)
            {
                if (ixinbuf == 0)
                {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2))
                {
                    ctcharsinbuf = 1;
                }
                else
                {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4)
            {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++)
                {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak)
            {
                break;
            }
        }
    }
    
    return theData;
}

- (NSString *) getMusicData:(NSString *)musicId
{
    NSString *postString = [NSString stringWithFormat:@"musicId=%@",musicId];
    
    NSString *musicFileName=[NSString stringWithFormat:@"music_%@.mp3",musicId  ];
    NSURL *url = [NSURL URLWithString:@"https://10.201.226.129:443/TestDeliveryWeb/CTB/getMp3.do"];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    //CODE TO bypass invalid certificate :
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    NSString *msgLength = [NSString stringWithFormat:@"%d",[postString length]];
    [req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error=nil;
    
    NSURLResponse *resp=[[NSURLResponse alloc] init];
    
    NSData *responseData=[NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
    if (error) {
        return @"<ERROR><HEADER></HEADER><MESSAGE>Connection to Server Lost, Unable to Download Music Data</MESSAGE><CODE>556</CODE></ERROR>";
    }
    
    ////NSLog(@"Music file ( %u bytes) downloaded",responseData.length);
    
    //Getting save path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *musicFileNameWithPath =[path stringByAppendingPathComponent:musicFileName];
    
    //Saving music
    [responseData writeToFile:musicFileNameWithPath atomically:YES];

    musicPath=musicFileNameWithPath;
    ////NSLog(@"Music File saved to %@ ",musicPath);
    [self playMusic:musicId];
    
    return @"<result>File_Downloaded</result>";
    
}

- (NSString *) playMusic:(NSString *)musicId
{
    if (musicPath&&![musicPath isEqualToString:@""]) {
        
        musicPlayer = [[MusicPlayerUtil alloc] initWithFileName:musicPath];
        
        
        ////NSLog(@"Music player set to path %@",musicPath);
        [musicPlayer startPlaying];
        
    }
    return @"<MUSIC PLAYING>";
}


- (NSString *) stopMusic:(NSString *)musicId
{
    if (musicPlayer) {
        
        [musicPlayer stopPlaying];
        musicPlayer=nil;
        
    }
    
    return @"<MUSIC STOPPED>";

}


- (NSString *) setVolume:(NSString *) volume
{
    NSString *result=@"<OK />";
    if (musicPlayer) {
        result=[musicPlayer setVolume:volume];
    }
    return result;
}

- (NSString *) getTEItemsPath
{
    //NSLog(@"TE Items Path : %@",teItemsPath);
    return teItemsPath;
}


//Parser delegate code:-
NSMutableDictionary *attributesByElement;
NSMutableString *elementString;


-(void)parserDidStartDocument:(NSXMLParser *)parser{
    itemData = [[NSMutableDictionary alloc] init];
    attributesByElement = [[NSMutableDictionary alloc] init];
    elementString = [[NSMutableString alloc] init];
    fileParts = [[NSMutableArray alloc] init];
    
}




- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)nameSpaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if (attributeDict)
    {
        [attributesByElement setObject:attributeDict forKey:elementName];
        
    }
    [elementString setString:@""];
    // Make sure the elementString is blank and ready to find characters
    // [elementString setString:@""];
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Save foundCharacters for later
    [elementString appendString:string];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"tracker"]) {
        
        NSDictionary *attributes = [attributesByElement objectForKey:@"tracker"];
        // [itemData setObject:[elementString copy] forKey:elementName];
        //[itemData addEntriesFromDictionary:attributes];
        
        itemData = attributes;
        
        [fileParts addObject:[itemData objectForKey:@"value"]];
    }
    [attributesByElement removeObjectForKey:elementName];
    [elementString setString:@""];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    attributesByElement = nil;
    elementString = nil;
}
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    ////NSLog(@"%@ with error %@",NSStringFromSelector(_cmd),parseError.localizedDescription);
}


@end
