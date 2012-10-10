//
//  NCEpisodesList.m
//  Netcaster
//
//  Created by Stuart Moore on 10/2/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCEpisodesList.h"
#import "Episode.h"
#import "Show.h"

@implementation NCEpisodesList

#pragma mark - Table

- (void)reloadTable
{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"published" ascending:YES];
    NSArray *sortedEpisodes = [self.show.episodes sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unwatched == %@", [NSNumber numberWithBool:YES]];
    self.episodes = [sortedEpisodes filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];
}

#pragma mark Delegate/DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
    return self.episodes.count;
}

- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(NSInteger)row
{
    Episode *episode = [self.episodes objectAtIndex:row];
    episode.tableController = self;
    
    return episode;
}
/*
- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn*)column row:(NSInteger)row
{
    return self.unwatchedEpisodeRowView;
}
*/
- (CGFloat)tableView:(NSTableView*)tableView heightOfRow:(NSInteger)row
{
    float height = (tableView.visibleRect.size.height/self.episodes.count > 200)
                    ? tableView.visibleRect.size.height/self.episodes.count:200;
    
    height -= 2;
    
    return height;
}

@end
