//
//  Episode.h
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Enclosure, Show;

@interface Episode : NSManagedObject

@property (nonatomic, retain) NSDate * aired;
@property (nonatomic, retain) NSString * cast;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * descShort;
@property (nonatomic, retain) NSDate * expires;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSDate * published;
@property (nonatomic, retain) NSNumber * timecode;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unwatched;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSSet *enclosures;
@property (nonatomic, retain) Show *show;
@end

@interface Episode (CoreDataGeneratedAccessors)

- (void)addEnclosuresObject:(Enclosure *)value;
- (void)removeEnclosuresObject:(Enclosure *)value;
- (void)addEnclosures:(NSSet *)values;
- (void)removeEnclosures:(NSSet *)values;

@end