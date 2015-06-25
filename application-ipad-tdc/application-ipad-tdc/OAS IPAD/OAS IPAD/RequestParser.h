//
//  RequestParser.h
//  
//
//  Created by Shayan Roychoudhury on 9/18/12.
//
//

#import <Foundation/Foundation.h>

@interface RequestParser : NSXMLParser <NSXMLParserDelegate>
@property (unsafe_unretained, readonly) NSMutableDictionary *itemData;
@end
