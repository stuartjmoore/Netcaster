//
//  Episode.h
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Show;

@interface Episode : NSManagedObject

@property (nonatomic, retain) NSDate * aired;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * expires;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSDate * published;
@property (nonatomic, retain) NSNumber * timecode;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unwatched;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * descShort;
@property (nonatomic, retain) NSString * cast;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) Show *show;
@property (nonatomic, retain) NSSet *enclosures;
@end

@interface Episode (CoreDataGeneratedAccessors)

- (void)addEnclosuresObject:(NSManagedObject *)value;
- (void)removeEnclosuresObject:(NSManagedObject *)value;
- (void)addEnclosures:(NSSet *)values;
- (void)removeEnclosures:(NSSet *)values;

@end
