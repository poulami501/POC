//
//  ContentAction.h
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 10/5/12.
//  Copyright (c) 2012 mcgrawhill ctb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "ZipArchive.h"
#import "ContentXMLParserDelegate.h"
#import "LoginResponseParser.h"
#import "MusicPlayerUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface ContentAction : NSObject <NSXMLParserDelegate>
{
    NSMutableDictionary *subtests;
    NSXMLParser *parser;
    NSURL *fileUrl;
    NSMutableArray *fileParts;
    NSString *extractedfilesfolder;
    NSDictionary *itemData;
    NSMutableDictionary *images;
    NSMutableDictionary *items;
    NSString *itemCache;
}

//@property (strong)NSXMLParser *parser;
//@property (assign)NSURL *url;
//@property (strong)NSURL *fileUrl;
//@property (readonly) NSDictionary *itemData;
//@property (strong) NSMutableArray *fileParts;
//@property (strong, nonatomic) NSMutableData *fileData;
//@property (strong) NSString *extractedfilesfolder;
//@property (strong) NSMutableDictionary *images;
//@property (strong) NSMutableDictionary *subtests;
//@property (strong) NSMutableDictionary *items;
@property (strong) NSString *contentURI;
@property (strong, nonatomic) NSString *musicPath;
@property (strong, nonatomic) MusicPlayerUtil *musicPlayer;
@property (strong) NSString *teItemsPath;


//Methods Called from within this class
-(NSString *) downloadSubTest:(NSString * ) subTestId From:(NSString *) URL withHash: (NSString *) hash andKey: (NSString *) key;
-(NSString *) decryptFile:(NSString *) fileName WithHash:(NSString *) hash WithKey:(NSString *)key;
-(NSString *) getItem:(NSString *) itemId withHash:(NSString *) hash WithKey:(NSString *)key;
-(void) processContent:(NSString *) Content;
-(NSString *) getImagebyId:(NSString *) imageId;
-(NSString *) getItembyId:(NSString *) itemId;
-(BOOL) downloadContentFromURL: (NSString *) trackerURL;

+(void) deleteCache;
+(NSString *) doUTF8Chars:(NSString *) input;
+(NSData *)base64DataFromString: (NSString *)string;

//Methods called from RequestHandler

- (NSString *) downloadFileparts:(NSString *)xmlString;
- (NSString *) getSubtest:(NSString *)xml;
- (NSString *) getItem:(NSString *)xml;
- (NSString *) getImage:(NSString *)xml;
- (NSString *) getMusicData:(NSString *)musicId;
- (NSString *) downloadItem:(NSString *)xml;
- (NSString *) playMusic:(NSString *)musicId;
- (NSString *) stopMusic:(NSString *)musicId;
- (NSString *) getTEItemsPath;
- (NSString *) setVolume:(NSString *) volume;

@end
