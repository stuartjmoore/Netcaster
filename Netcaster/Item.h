//
//  Item.h
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString *title, *subtitle;
@property (nonatomic, retain) Group *group;

- (id)items;

@end
