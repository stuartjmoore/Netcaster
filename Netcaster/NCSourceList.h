//
//  NCSourceList.h
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCEpisodesList;

@interface NCSourceList : NSTreeController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, weak) IBOutlet NCEpisodesList *episodesController;
@property (nonatomic, weak) IBOutlet NSTableView *episodesTable;
@property (nonatomic, weak) IBOutlet NSTextField *showView;

@property (nonatomic, strong) NSDraggingSession *draggingSession;
@property (nonatomic, strong) NSTreeNode *draggingItem;
@property (nonatomic, strong) id draggingObject;

@end
