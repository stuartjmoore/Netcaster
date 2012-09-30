//
//  Channel.h
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Show;

@interface Channel : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSSet *shows;
@property (nonatomic, retain) NSSet *livestreams;
@property (nonatomic, retain) Item *item;
@end

@interface Channel (CoreDataGeneratedAccessors)

- (void)addShowsObject:(Show *)value;
- (void)removeShowsObject:(Show *)value;
- (void)addShows:(NSSet *)values;
- (void)removeShows:(NSSet *)values;

- (void)addLivestreamsObject:(NSManagedObject *)value;
- (void)removeLivestreamsObject:(NSManagedObject *)value;
- (void)addLivestreams:(NSSet *)values;
- (void)removeLivestreams:(NSSet *)values;

@end
