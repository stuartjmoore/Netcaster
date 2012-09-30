//
//  Enclosure.h
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Episode;

@interface Enclosure : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Episode *episode;

@end
