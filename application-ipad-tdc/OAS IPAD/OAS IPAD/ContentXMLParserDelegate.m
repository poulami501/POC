//
//  ContentXMLParserDelegate.m
//  CordovaDemo
//
//  Created by Shayan Roychoudhury on 9/17/12.
//
//

#import "ContentXMLParserDelegate.h"

@implementation ContentXMLParserDelegate {

    NSMutableDictionary *_imageData;
    NSMutableDictionary *_attributesByElement;
    NSMutableString *_elementString;
    NSString *_zipData;
    
}

//@synthesize imageData;

-(NSDictionary *)imageData{
    
    return [_imageData copy];
}


-(NSString *)zipData{
    
    return [_zipData copy];
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _imageData = [[NSMutableDictionary alloc] init];
    _attributesByElement = [[NSMutableDictionary alloc] init];
    _elementString = [[NSMutableString alloc] init];
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if (attributeDict) [_attributesByElement setObject:attributeDict forKey:elementName];
    // Make sure the elementString is blank and ready to find characters
    [_elementString setString:@""];
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Save foundCharacters for later
    [_elementString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"image"]) {
        
        NSString *imgId = [[_attributesByElement objectForKey:elementName] objectForKey:@"id"];
        //NSLog(@"ID : %@",imgId);
        
        if (imgId) [_imageData setObject:[_elementString copy] forKey:imgId];
       // NSLog(@"Image : %@",_imageData);
        
    }
    else if ([elementName isEqualToString:@"htmldata"])
    {
        _zipData =[_elementString copy];
    }
    
    
    [_attributesByElement removeObjectForKey:elementName];
    [_elementString setString:@""];
}
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    _attributesByElement = nil;
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

