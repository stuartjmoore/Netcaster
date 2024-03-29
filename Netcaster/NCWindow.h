//
//  NCWindow.h
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCShowsList, NCAddModal;

@interface NCWindow : NSWindow <NSWindowDelegate, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NCAddModal *addShowModal;
@property (nonatomic, weak) IBOutlet NSOutlineView *showsList;

@property (nonatomic, weak) IBOutlet NSView *detailView;
@property (nonatomic, weak) IBOutlet NSScrollView *recentEpisodesView;
@property (nonatomic, weak) IBOutlet NSTableView *allEpisodesTable;

@property (nonatomic, weak) IBOutlet NSPopover *showInfoPopover;

- (IBAction)dispalyAddNewShowModal:(id)sender;
- (IBAction)importOPML:(id)sender;

- (IBAction)removeShowOrGroup:(id)sender;
- (IBAction)refreshShowOrGroup:(id)sender;
- (IBAction)renameShowOrGroup:(id)sender;
- (IBAction)markWatchedShowOrGroup:(id)sender;

- (IBAction)refreshAll:(id)sender;

- (IBAction)displayShowInfo:(id)sender;

@end
