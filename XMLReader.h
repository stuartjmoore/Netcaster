//
//  XMLReader.h
//
//

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject<NSXMLParserDelegate>

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error;
+ (NSString*)stringFromDictionary:(NSDictionary*)dictionary withKeys:(NSString*)format, ...;

@end