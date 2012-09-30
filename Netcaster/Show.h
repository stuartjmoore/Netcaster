//
//  Show.h
//  Netcaster
//
//  Created by Stuart Moore on 9/29/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Show : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSOrderedSet *episodes;
@property (nonatomic, retain) Group *group;
@end

@interface Show (CoreDataGeneratedAccessors)

- (id)shows;

- (void)insertObject:(NSManagedObject *)value inEpisodesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEpisodesAtIndex:(NSUInteger)idx;
- (void)insertEpisodes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEpisodesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEpisodesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceEpisodesAtIndexes:(NSIndexSet *)indexes withEpisodes:(NSArray *)values;
- (void)addEpisodesObject:(NSManagedObject *)value;
- (void)removeEpisodesObject:(NSManagedObject *)value;
- (void)addEpisodes:(NSOrderedSet *)values;
- (void)removeEpisodes:(NSOrderedSet *)values;
@end
