//
//  XMLReader.m
//

#import "XMLReader.h"

static NSString *const kXMLReaderTextNodeKey = @"text";

@interface XMLReader()
@property (strong, nonatomic) NSMutableArray *dictionaryStack;
@property (strong, nonatomic) NSMutableString *textInProgress;
@property (assign, nonatomic) NSError *__autoreleasing *error;
@end

@interface XMLReader (Internal)
- (NSDictionary *)objectWithData:(NSData *)data;
@end

@implementation XMLReader
@synthesize dictionaryStack, textInProgress;

#pragma mark - Public methods

+ (NSDictionary*)dictionaryForXMLData:(NSData*)data error:(NSError**)errorPointer
{
    XMLReader *reader = [XMLReader new];
	reader.error = errorPointer;
    return [reader objectWithData:data];
}

+ (NSDictionary*)dictionaryForXMLString:(NSString*)string error:(NSError**)errorPointer
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data error:errorPointer];
}

+ (NSString*)stringFromDictionary:(NSDictionary*)dictionary withKeys:(NSString*)firstKey, ...
{
    id temp = dictionary;
    
    va_list args;
    va_start(args, firstKey);
    for(NSString *arg = firstKey; arg != nil; arg = va_arg(args, NSString*))
    {
        if([temp isKindOfClass:NSDictionary.class])
            temp = [temp objectForKey:arg];
        else
            return nil;
    }
    va_end(args);
    
    if([temp isKindOfClass:NSString.class])
        return [temp stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    else
        return nil;
}

#pragma mark - Parsing

- (NSDictionary*)objectWithData:(NSData *)data
{
    self.dictionaryStack = [[NSMutableArray alloc] init];
    self.textInProgress = [[NSMutableString alloc] init];
    
    // Initialize the stack with a fresh dictionary
    [self.dictionaryStack addObject:[NSMutableDictionary dictionary]];
    
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    // Return the stack's root dictionary on success
    if (success)
    {
        NSDictionary *resultDict = [self.dictionaryStack objectAtIndex:0];
        return resultDict;
    }
    
    return nil;
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict
{
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [dictionaryStack lastObject];
    
    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];
            
            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [dictionaryStack lastObject];
    
    // Set the text property
    if ([textInProgress length] > 0)
    {
        [dictInProgress setObject:textInProgress forKey:kXMLReaderTextNodeKey];
        
        // Reset the text
        self.textInProgress = [[NSMutableString alloc] init];
    }
    
    // Pop the current dict
    [dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value
    [textInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser's error object
	(*self.error) = parseError;
}

@end