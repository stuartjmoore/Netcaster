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

#pragma mark Delegate

- (CGFloat)tableView:(NSTableView*)tableView heightOfRow:(NSInteger)row
{
    float height = (tableView.visibleRect.size.height/tableView.numberOfRows > 200)
                    ? tableView.visibleRect.size.height/tableView.numberOfRows-2:200;
    
    return height;
}

@end
