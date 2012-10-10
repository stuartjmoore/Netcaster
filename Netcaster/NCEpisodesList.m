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
    /*NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"published" ascending:YES];
    NSArray *sortedEpisodes = [self.show.episodes sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unwatched == %@", [NSNumber numberWithBool:YES]];
    self.episodes = [sortedEpisodes filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];*/
}

#pragma mark Delegate

- (CGFloat)tableView:(NSTableView*)tableView heightOfRow:(NSInteger)row
{
    float height = (tableView.visibleRect.size.height/tableView.numberOfRows > 200)
                    ? tableView.visibleRect.size.height/tableView.numberOfRows:200;
    
    height -= 2;
    
    return height;
}

@end
