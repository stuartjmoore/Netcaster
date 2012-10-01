//
//  Channel.h
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class Livestream, Show;

@interface Channel : Item

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSSet *livestreams;
@property (nonatomic, retain) NSSet *shows;
@end

@interface Channel (CoreDataGeneratedAccessors)

- (void)addLivestreamsObject:(Livestream *)value;
- (void)removeLivestreamsObject:(Livestream *)value;
- (void)addLivestreams:(NSSet *)values;
- (void)removeLivestreams:(NSSet *)values;

- (void)addShowsObject:(Show *)value;
- (void)removeShowsObject:(Show *)value;
- (void)addShows:(NSSet *)values;
- (void)removeShows:(NSSet *)values;

@end
