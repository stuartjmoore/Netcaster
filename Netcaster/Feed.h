//
//  Feed.h
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum {
    FeedTypePodcast = 0,
    FeedTypeHulu = 1,
    FeedTypeYouTubePlaylist = 2,
    FeedTypeYouTubeUser = 3
} FeedType;

@class Show;

@interface Feed : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * updated;
// update freq
// get average time interval between shows
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Show *show;

@end
