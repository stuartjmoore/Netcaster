//
//  Page.h
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"


@interface Page : Item

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * source;

@end
