//
//  CoreLinkViewController.m
//  CoreLink
//
//  Created by Chinmay Kulkarni on 7/30/12.
//  Copyright (c) 2012 __TCS__. All rights reserved.
//

#import "CoreLinkViewController.h"
#define FRAME_SIZE 110
//#define CHUNK_SIZE 1024
NSString * const baseTable = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation CoreLinkViewController

//@synthesize recording;



+ (NSString *) encode:(NSData *)bytes {
    NSMutableString * tmp = [[NSMutableString alloc] init];
    int i = 0;
    int pos;
    
    const char *byteptr = [bytes bytes];
    for (i = 0; i < ([bytes length] - bytes.length % 3); i += 3) {
        pos = (int)((byteptr[i] >> 2) & 63);
        [tmp appendFormat:@"%c",[baseTable characterAtIndex:pos]];
        pos = (int)(((byteptr[i] & 3) << 4) + ((byteptr[i + 1] >> 4) & 15));
        [tmp appendFormat:@"%c",[baseTable characterAtIndex:pos]];
        pos = (int)(((byteptr[i + 1] & 15) << 2) + ((byteptr[i + 2] >> 6) & 3));
        [tmp appendFormat:@"%c",[baseTable characterAtIndex:pos]];
        pos = (int)(((byteptr[i + 2]) & 63));
        [tmp appendFormat:@"%c",[baseTable characterAtIndex:pos]];
        if (((i + 2) % 56) == 0) {
            [tmp appendString:@"\r\n"];
        }
    }
    
    if (bytes.length % 3 != 0) {
        if (bytes.length % 3 == 2) {
            pos = (int)((byteptr[i] >> 2) & 63);
            [tmp appendFormat:@"%c",[baseTable characterAtIndex:pos]];
            pos = (int)(((byteptr[i] & 3) << 4) + ((byteptr[i + 1] >> 4) & 15));
            [tmp appendFormat:@"%c",[baseTable characterAtIndex:pos]];
            pos = (int)((byteptr[i + 1] & 15) << 2);
            [tmp appendFormat:@"%c",[baseTable characterAtIndex:pos]];
            [tmp appendString:@"="];
        }
        else if (bytes.length % 3 == 1) {
            pos = (int)((byteptr[i] >> 2) & 63);
            [tmp appendFormat:@"%c",[baseTable characterAtIndex:pos]];
            pos = (int)((byteptr[i] & 3) << 4);
            [tmp appendFormat:@"%c",[baseTable characterAtIndex:pos]];
            [tmp appendString:@"=="];
        }
    }
    return tmp ;
}

+ (NSString *) decodeToByteArray:(NSString *)src {
    NSMutableString * bytes = [[NSMutableString alloc] init];//used string insted of Array
    NSMutableString * buf = [[NSMutableString alloc] initWithString:src] ;
    int i = 0;
    unichar c = ' ';
    unichar oc = ' ';
    
    while (i < [buf length]) {
        oc = c;
        c = [buf characterAtIndex:i];
        if (oc == '\r' && c == '\n') {
            [buf deleteCharactersInRange:NSMakeRange(i,1)];
            [buf deleteCharactersInRange:NSMakeRange(i - 1,1)];
            i -= 2;
        }
        else if (c == '\t') {
            [buf deleteCharactersInRange:NSMakeRange(i,1)];
            i--;
        }
        else if (c == ' ') {
            i--;
        }
        i++;
    }
    
    if ([buf length] % 4 != 0) {
        @throw [[NSException alloc] initWithName:@"Base64 decoding invalid length" reason:@"Base64 decoding invalid length" userInfo:nil] ;
    }
//    bytes = [NSArray array];
    int index = 0;
    
    for (i = 0; i < [buf length]; i += 4) {
        char data = 0;
        int nGroup = 0;
        
        for (int j = 0; j < 4; j++) {
            unichar theChar = [buf characterAtIndex:i + j];
            if (theChar == '=') {
                data = 0;
            }
            else {
                data = (char)[self getBaseTableIndex:theChar];
            }
            if (data == -1) {
                @throw [[NSException alloc] initWithName:@"Base64 decoding bad character" reason:@"Base64 decoding bad character" userInfo:nil] ;
            }
            nGroup = 64 * nGroup + data;
        }
        
        //    bytes[index] = (char)(255 & (nGroup >> 16));
        [bytes appendFormat:@"%c",(char)(255 & (nGroup >> 16))];
        index++;
        //    bytes[index] = (char)(255 & (nGroup >> 8));
        [bytes appendFormat:@"%c",(char)(255 & (nGroup >> 8))];
        index++;
        //    bytes[index] = (char)(255 & (nGroup));
        [bytes appendFormat:@"%c",(char)(255 & nGroup)];
        index++;
    }
    
//    NSMutableString * newBytes = [NSMutableString string];
//    
//    for (i = 0; i < index; i++) {
//        //    newBytes[i] = bytes[i];
//        [newBytes appendFormat:@"%c",[bytes characterAtIndex:i]];
//    }
    
    return bytes;
}

+ (char) getBaseTableIndex:(unichar)c {
    char index = -1;
    
    for (char i = 0; i < [baseTable length]; i++) {
        if ([baseTable characterAtIndex:i] == c) {
            index = i;
            break;
        }
    }
    
    return index;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    //for decryption
//    [self decryptFile:@"38501302.ecp" WithHash:@"C5D51ABA5B4BF37CEDE8CA361E318F9E" WithKey:@"n7673nBJ2n27bB4oAfme7Ugl5VV42g8"];A4EQgxIW2COi6Hjn 
    
    [self decryptMP3File:@"abc.enc" WithKey:@"A4EQgxIW2COi6Hjn"];
    
    [self removeFile:@"abc.mp3"];
    //for Base 64
//    NSString *msg =@"hjadfhjkashf";
//    NSString * base64String = [CoreLinkViewController encode:[NSData dataWithBytes:[msg UTF8String] length:[msg length]]];
//    NSLog(@"%@",base64String);
//    NSString *decoded = [CoreLinkViewController decodeToByteArray:base64String];
//    NSLog(@"%@",decoded);
    
    //for JSON parsing
//    [self parseJSON:@"abc.txt"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark Class Methods
-(void) parseJSON:(NSString *) filename{
    @try {
        NSArray * fileNameArray = [filename componentsSeparatedByString:@"."];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileNameArray objectAtIndex:0] ofType:[fileNameArray objectAtIndex:1]];
        
        NSError *error=nil;
        NSData* content = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
        if (error) {
            NSLog(@"%@",[error description]);
        }
        
        NSDictionary *jsonData = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:content options:NSJSONReadingMutableLeaves error:&error]];
        
        NSLog(@"param1: %@",[[jsonData objectForKey:@"pluginrequest"] objectForKey:@"param1"]);
        NSLog(@"param2: %@",[[jsonData objectForKey:@"pluginrequest"] objectForKey:@"param2"]);
        NSLog(@"param3: %@",[[jsonData objectForKey:@"pluginrequest"] objectForKey:@"param3"]);
        NSLog(@"%@",jsonData);
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *textFilePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"json.plist"]];
        
        error = nil;
        [jsonData writeToFile:textFilePath atomically:YES];
//        [jsonData writeToFile:textFilePath options:NSDataWritingFileProtectionComplete error:&error];

    }
    @catch (NSException *exception) {
        
    }
}

- (void)removeFile:(NSString *)filename
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:filename]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];  
    if ([fileManager fileExistsAtPath:filePath]) 
    {
        NSError *error;
        if (![fileManager removeItemAtPath:filePath error:&error])
        {
            NSLog(@"Error removing file: %@", error); 
        };
    }
}

-(void) decryptFile:(NSString *) fileName WithHash:(NSString *) hash WithKey:(NSString *)key{
    @try{
        NSArray * fileNameArray = [fileName componentsSeparatedByString:@"."];
    
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileNameArray objectAtIndex:0] ofType:[fileNameArray objectAtIndex:1]];
    
        NSError *error=nil;
        NSData* content = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
        if (error) {
            NSLog(@"%@",[error description]);
        }

        CC_MD5_CTX md5data;
        
        CC_MD5_Init(&md5data);
        
        CC_MD5_Update(&md5data, [content bytes], [content length]);
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &md5data);
        NSString* hashFromEncryptedFile = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7], digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]];
        NSString *recoveredHash = [hashFromEncryptedFile uppercaseString];
        NSLog(@"%@",recoveredHash);
        
        if ( hash != nil || [recoveredHash isEqualToString:hash]) {
            NSLog(@"Encryption begins");
            
            CC_MD5_CTX md51;
            CC_MD5_Init(&md51);
            NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:[key length]];
            CC_MD5_Update(&md51,[keyData bytes] , [key length]);
            unsigned char generatedKey[CC_MD5_DIGEST_LENGTH];
            CC_MD5_Final(generatedKey, &md51);
            
            NSString* dehashedKey = [NSString stringWithFormat: @"%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c", generatedKey[0], generatedKey[1], generatedKey[2], generatedKey[3], generatedKey[4], generatedKey[5], generatedKey[6], generatedKey[7], generatedKey[8], generatedKey[9], generatedKey[10], generatedKey[11], generatedKey[12], generatedKey[13], generatedKey[14], generatedKey[15]];

            NSLog(@"Dehashed Key: %@",dehashedKey);
            
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
            
            if (cryptorStatus == kCCSuccess) NSLog(@"Cryptor SUCCESS");
            else if (cryptorStatus == kCCParamError) NSLog(@"Cryptor PARAM ERROR");
            else if (cryptorStatus == kCCMemoryFailure) NSLog(@"Cryptor MEMORY FAILURE");
            
            ccStatus = CCCryptorUpdate(refer,vplainText, plainTextBufferSize, (void *)bufferPtr, bufferPtrSize, &movedBytes);
            
            if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
            else if (ccStatus == kCCParamError) NSLog(@"PARAM ERROR");
            else if (ccStatus == kCCBufferTooSmall) NSLog(@"BUFFER TOO SMALL");
            else if (ccStatus == kCCMemoryFailure) NSLog(@"MEMORY FAILURE");
            else if (ccStatus == kCCAlignmentError) NSLog(@"ALIGNMENT");
            else if (ccStatus == kCCDecodeError) NSLog(@"DECODE ERROR");
            else if (ccStatus == kCCUnimplemented) NSLog(@"UNIMPLEMENTED");
            
            NSData *textout = [NSData dataWithBytes:bufferPtr length:(NSUInteger)movedBytes];
            NSString *result = [[ NSString alloc ] initWithData: textout encoding:NSUTF8StringEncoding];
            NSLog(@"res: %@",result);
            
//            const char *finalString = [result UTF8String];
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *textFilePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Textout.txt"]];

            error = nil;
            [textout writeToFile:textFilePath options:NSDataWritingFileProtectionComplete error:&error];
//            [result writeToFile:textFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error]; 
            if (error) {
                NSLog(@"%@",[error description]);
            }
            
            NSLog(@"Buffer Size = %lu",plainTextBufferSize);
            NSLog(@"Moved bytes = %lu",movedBytes);
            
        }
        else{
            NSLog(@"Hash mismatch");
        }
        
    }
    @catch(NSException *exception){
        NSLog(@"Exception in --> <CoreLinkViewController><decryptFile: WithHash: WithKey> Error message-->%@",[exception reason]);
    }
}

-(void) decryptMP3File:(NSString *) fileName WithKey:(NSString *)key{
    @try{
        NSArray * fileNameArray = [fileName componentsSeparatedByString:@"."];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileNameArray objectAtIndex:0] ofType:[fileNameArray objectAtIndex:1]];
        
        NSError *error=nil;
        NSString *fileString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        
        NSString *base64DecodedString = [CoreLinkViewController decodeToByteArray:fileString];
        NSLog(@"%@",base64DecodedString);
        if (error) {
            NSLog(@"%@",[error description]);
        }
        
        NSData* content = [NSData dataWithBytes:[base64DecodedString UTF8String] length:[base64DecodedString length]];
        
        
        CC_MD5_CTX md5data;
        
        CC_MD5_Init(&md5data);
        
        CC_MD5_Update(&md5data, [content bytes], [content length]);
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &md5data);
        NSString* hashFromEncryptedFile = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7], digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]];
        NSString *recoveredHash = [hashFromEncryptedFile uppercaseString];
        NSLog(@"%@",recoveredHash);
        
        //        if ( hash != nil || [recoveredHash isEqualToString:hash]) {
        NSLog(@"Encryption begins");
        
        CC_MD5_CTX md51;
        CC_MD5_Init(&md51);
        NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:[key length]];
        CC_MD5_Update(&md51,[keyData bytes] , [key length]);
        unsigned char generatedKey[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(generatedKey, &md51);
        
        NSString* dehashedKey = [NSString stringWithFormat: @"%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c", generatedKey[0], generatedKey[1], generatedKey[2], generatedKey[3], generatedKey[4], generatedKey[5], generatedKey[6], generatedKey[7], generatedKey[8], generatedKey[9], generatedKey[10], generatedKey[11], generatedKey[12], generatedKey[13], generatedKey[14], generatedKey[15]];
        
        NSLog(@"Dehashed Key: %@",dehashedKey);
        
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
        
        if (cryptorStatus == kCCSuccess) NSLog(@"Cryptor SUCCESS");
        else if (cryptorStatus == kCCParamError) NSLog(@"Cryptor PARAM ERROR");
        else if (cryptorStatus == kCCMemoryFailure) NSLog(@"Cryptor MEMORY FAILURE");
        
        ccStatus = CCCryptorUpdate(refer,vplainText, plainTextBufferSize, (void *)bufferPtr, bufferPtrSize, &movedBytes);
        
        if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
        else if (ccStatus == kCCParamError) NSLog(@"PARAM ERROR");
        else if (ccStatus == kCCBufferTooSmall) NSLog(@"BUFFER TOO SMALL");
        else if (ccStatus == kCCMemoryFailure) NSLog(@"MEMORY FAILURE");
        else if (ccStatus == kCCAlignmentError) NSLog(@"ALIGNMENT");
        else if (ccStatus == kCCDecodeError) NSLog(@"DECODE ERROR");
        else if (ccStatus == kCCUnimplemented) NSLog(@"UNIMPLEMENTED");
        
        NSData *textout = [NSData dataWithBytes:bufferPtr length:(NSUInteger)movedBytes];
        NSString *result = [[ NSString alloc ] initWithData: textout encoding:NSUTF8StringEncoding];
        NSLog(@"res: %@",result);
        
        //            const char *finalString = [result UTF8String];
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *textFilePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"abc.mp3"]];
        
        error = nil;
        [textout writeToFile:textFilePath options:NSDataWritingFileProtectionComplete error:&error];
        //            [result writeToFile:textFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error]; 
        if (error) {
            NSLog(@"%@",[error description]);
        }
        
        NSLog(@"Buffer Size = %lu",plainTextBufferSize);
        NSLog(@"Moved bytes = %lu",movedBytes);
        
        //        }
        //        else{
//        NSLog(@"Hash mismatch");
        //        }
        
    }
    @catch(NSException *exception){
        NSLog(@"Exception in --> <CoreLinkViewController><decryptFile: WithHash: WithKey> Error message-->%@",[exception reason]);
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
