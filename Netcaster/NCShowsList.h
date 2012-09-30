//
//  NCShowsList.h
//  Netcaster
//
//  Created by Stuart Moore on 9/29/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Group.h"

@interface NCShowsList : NSOutlineView <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end
