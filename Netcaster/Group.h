//
//  Group.h
//  Netcaster
//
//  Created by Stuart Moore on 10/10/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString *title, *subtitle;
@property (nonatomic, retain) NSSet *items;

- (id)episodes;

@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item*)value;
- (void)removeItemsObject:(Item*)value;
- (void)addItems:(NSSet*)values;
- (void)removeItems:(NSSet*)values;

@end
