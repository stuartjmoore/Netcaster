//
//  NCEpisodesList.m
//  Netcaster
//
//  Created by Stuart Moore on 10/2/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCEpisodesList.h"
#import "Episode.h"

@implementation NCEpisodesList

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return self.episodes.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)rowIndex
{
    Episode *episode = [self.episodes objectAtIndex:rowIndex];
    
    return episode;
}

@end
