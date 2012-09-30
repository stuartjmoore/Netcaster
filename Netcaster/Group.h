//
//  Group.h
//  Netcaster
//
//  Created by Stuart Moore on 9/29/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *shows;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inShowsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromShowsAtIndex:(NSUInteger)idx;
- (void)insertShows:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeShowsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInShowsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceShowsAtIndexes:(NSIndexSet *)indexes withShows:(NSArray *)values;
- (void)addShowsObject:(NSManagedObject *)value;
- (void)removeShowsObject:(NSManagedObject *)value;
- (void)addShows:(NSOrderedSet *)values;
- (void)removeShows:(NSOrderedSet *)values;
@end
