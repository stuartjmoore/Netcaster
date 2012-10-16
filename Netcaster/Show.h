//
//  Show.h
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class Channel, Episode, Feed;

@interface Show : Item

@property (nonatomic, retain) NSString *cast;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *genre;
@property (nonatomic, retain) NSData *image;
@property (nonatomic, retain) NSNumber *hasNew;
@property (nonatomic, retain) NSString *schedule;
@property (nonatomic, retain) NSNumber *unwatchedCount;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) Channel *channel;
@property (nonatomic, retain) NSSet *episodes;
@property (nonatomic, retain) NSSet *feeds;

- (NSArray*)unwatchedEpisodes;

- (NSString*)allEpisodesString;

- (void)markAllWatched;

- (void)reload;
- (void)updatePodcastFeed:(Feed*)feed;

@end

@interface Show (CoreDataGeneratedAccessors)

- (void)addEpisodesObject:(Episode *)value;
- (void)removeEpisodesObject:(Episode *)value;
- (void)addEpisodes:(NSSet *)values;
- (void)removeEpisodes:(NSSet *)values;

- (void)addFeedsObject:(Feed *)value;
- (void)removeFeedsObject:(Feed *)value;
- (void)addFeeds:(NSSet *)values;
- (void)removeFeeds:(NSSet *)values;

@end
