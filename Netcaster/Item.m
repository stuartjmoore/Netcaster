//
//  Item.m
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "Item.h"
#import "Group.h"


@implementation Item

@dynamic subtitle, title;
@dynamic sortIndex;
@dynamic group;

- (id)items
{
    return nil;
}

- (NSString*)unwatchedString
{
    return @"";
}
- (NSString*)recentEpisodesString
{
    return @"";
}
- (NSString*)allEpisodesString
{
    return @"";
}

@end
