//
//  Episode.m
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCEpisodesList.h"

#import "Episode.h"
#import "Enclosure.h"
#import "Show.h"

@implementation Episode

@dynamic aired;
@dynamic cast;
@dynamic desc;
@dynamic descShort;
@dynamic duration;
@dynamic expires;
@dynamic image;
@dynamic isNew;
@dynamic number;
@dynamic published;
@dynamic timecode;
@dynamic title;
@dynamic unwatched;
@dynamic website;
@dynamic enclosures;
@dynamic price, currency, rating;
@dynamic show;

@synthesize tableController = _tableController;

- (void)markUnwatched
{
    self.unwatched = [NSNumber numberWithBool:NO];
    
    self.show.unwatchedCount = [NSNumber numberWithInt:(self.show.unwatchedCount.intValue-1)];
    self.show.subtitle = [NSString stringWithFormat:@"%d", self.show.unwatchedCount.intValue];
    
    //[self.tableController reloadTable];
}

@end
