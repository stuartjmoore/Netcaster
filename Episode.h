//
//  Episode.h
//  Netcaster
//
//  Created by Stuart Moore on 9/29/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Show;

@interface Episode : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * published;
@property (nonatomic, retain) NSDate * expires;
@property (nonatomic, retain) NSDate * aired;
@property (nonatomic, retain) NSNumber * watched;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSNumber * timecode;
@property (nonatomic, retain) Show *show;

@end
