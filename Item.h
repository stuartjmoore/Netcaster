//
//  Item.h
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    ItemTypeShow    = 0,
    ItemTypeChannel = 1,
    ItemTypePage    = 2
} ItemType;

@class Channel, Group, Show, Page;

@interface Item : NSManagedObject

@property (nonatomic, retain) Group *group;

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Show *show;
@property (nonatomic, retain) Channel *channel;
@property (nonatomic, retain) Page *page;

- (id)items;

@end
