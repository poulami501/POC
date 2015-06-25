//
//  LoginResponseParser.m
//  OAS IPAD
//
//  Created by Shayan Roychoudhury on 9/21/12.
//  Copyright (c) 2012 mcgrawhill ctb. All rights reserved.
//

#import "ResponseParser.h"

@implementation ResponseParser
{
    NSMutableString *_elementString;
    NSMutableDictionary *attributesByElement;
    NSString *element;
}

@synthesize trackerinfo;

-(id) initWithString:(NSString *)string
{
    NSData *xmlData=[string dataUsingEncoding:NSUTF8StringEncoding];
    return [super initWithData:xmlData];
}

-(void) setElement:(NSString * ) elementName
{
    element = elementName;
}

-(NSString *) getAtrtributeValue:(NSString *) attributName;
{
    return [trackerinfo objectForKey:attributName];
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    trackerinfo = [[NSMutableDictionary alloc] init];
    _elementString = [[NSMutableString alloc] init];
    attributesByElement=[[NSMutableDictionary alloc]init];

}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    //Saving attributes if present
    if (attributeDict) [attributesByElement setObject:attributeDict forKey:elementName];

    //Setting the element string to blank
    [_elementString setString:@""];

}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Save foundCharacters for later
    [_elementString appendString:string];
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:element]) {
        // Pricing has an interesting attributes dictionary
        // So copy the entries to the item data
        NSDictionary *attributes = [attributesByElement objectForKey:element];
        [trackerinfo addEntriesFromDictionary:attributes];
    } 
    [attributesByElement removeObjectForKey:elementName];
    [_elementString setString:@""];
}
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    attributesByElement = nil;
    _elementString = nil;
}
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    //NSLog(@"%@ with error %@",NSStringFromSelector(_cmd),parseError.localizedDescription);
}
-(BOOL)parse{
    self.delegate = self;
    return [super parse];
}
@end
