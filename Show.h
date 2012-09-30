//
//  Show.h
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel, Episode, Item;

@interface Show : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * unwatchedCount;
@property (nonatomic, retain) NSNumber * isNewCount;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * channelName;
@property (nonatomic, retain) NSString * schedule;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSString * cast;
@property (nonatomic, retain) NSSet *episodes;
@property (nonatomic, retain) NSSet *feeds;
@property (nonatomic, retain) Channel *channel;
@property (nonatomic, retain) Item *item;
@end

@interface Show (CoreDataGeneratedAccessors)

- (void)addEpisodesObject:(Episode *)value;
- (void)removeEpisodesObject:(Episode *)value;
- (void)addEpisodes:(NSSet *)values;
- (void)removeEpisodes:(NSSet *)values;

- (void)addFeedsObject:(NSManagedObject *)value;
- (void)removeFeedsObject:(NSManagedObject *)value;
- (void)addFeeds:(NSSet *)values;
- (void)removeFeeds:(NSSet *)values;

@end
