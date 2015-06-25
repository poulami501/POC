//
//  RequestParser.m
//  
//
//  Created by Shayan Roychoudhury on 9/18/12.
//
//

#import "RequestParser.h"

@implementation RequestParser{
    NSMutableDictionary *_itemData;
    NSMutableDictionary *_attributesByElement;
    NSMutableString *_elementString;
}
-(NSDictionary *)itemData{
    return [_itemData copy];
}
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _itemData = [[NSMutableDictionary alloc] init];
    _attributesByElement = [[NSMutableDictionary alloc] init];
    _elementString = [[NSMutableString alloc] init];
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    // Save the attributes for later.
    if (attributeDict) [_attributesByElement setObject:attributeDict forKey:elementName];
    // Make sure the elementString is blank and ready to find characters
    [_elementString setString:@""];
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Save foundCharacters for later
    [_elementString appendString:string];
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    /*if ([elementName isEqualToString:@"status"]){
        // Element status only contains a string i.e. "OK"
        // Simply set a copy of the element value string in the itemData dictionary
        [_itemData setObject:[_elementString copy] forKey:elementName];
    } else*/
    if ([elementName isEqualToString:@"get_item"]) {
        // Pricing has an interesting attributes dictionary
        // So copy the entries to the item data
        NSDictionary *attributes = [_attributesByElement objectForKey:@"get_item"];
        //NSLog(@"Attributes %@",attributes);
        
        [_itemData addEntriesFromDictionary:attributes];
    } /*else if ([elementName isEqualToString:@"price"]) {
        // The element price occurs multiple times.
        // The meaningful designation occurs in the "class" attribute.
        NSString *class = [[_attributesByElement objectForKey:elementName] objectForKey:@"class"];
        if (class) [_itemData setObject:[_elementString copy] forKey:class];
    }*/
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
