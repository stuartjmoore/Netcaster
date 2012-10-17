//
//  Group.m
//  Netcaster
//
//  Created by Stuart Moore on 10/10/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "Group.h"
#import "Item.h"


@implementation Group

@dynamic subtitle, title;
@dynamic sortIndex;
@dynamic items;

- (id)episodes
{
    return nil;
}
- (id)unwatchedEpisodes
{
    return nil;
}
- (NSString*)allEpisodesString
{
    return @"";
}
- (NSString*)desc
{
    return @"";
}
- (NSImage*)imageValue
{
    return nil;
}

@end
