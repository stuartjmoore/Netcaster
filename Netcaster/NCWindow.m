//
//  NCWindow.m
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "XMLReader.h"

#import "NCAppDelegate.h"
#import "NCWindow.h"
#import "NCAddModal.h"

#import "StaticGroup.h"
#import "WatchBox.h"
#import "Group.h"
#import "Item.h"
#import "Show.h"
#import "Feed.h"

@implementation NCWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if(self)
    {
        self.delegate = self;
        
        self.showsList.floatsGroupRows = NO;
        [self.showsList registerForDraggedTypes:[NSArray arrayWithObjects:@"ItemsDropType", nil]];
    }
    return self;
}

- (void)awakeFromNib
{
    if([self isVisible])
        return;
        
    [self performSelector:@selector(expandAllItems) withObject:nil afterDelay:0.01f];
    
    self.recentEpisodesView.frame = self.detailView.bounds;
    self.recentEpisodesView.autoresizingMask = 63;
    [self.detailView addSubview:self.recentEpisodesView];
}
- (void)expandAllItems
{
    [self.showsList expandItem:nil expandChildren:YES];
    [self.showsList selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
}

#pragma mark - Menu bar Actions

- (IBAction)addNewShow:(id)sender
{
    if([NSPasteboard.generalPasteboard stringForType:NSStringPboardType])
        self.addShowModal.urlField.stringValue = [NSPasteboard.generalPasteboard stringForType:NSStringPboardType];
    else
        self.addShowModal.urlField.stringValue = @"";
    
    [self.addShowModal controlTextDidChange:nil];
    
    self.addShowModal.showDetailTitle.stringValue = @"";
    self.addShowModal.showDetailDesc.stringValue = @"";
    self.addShowModal.showDetailImage.image = nil;
    
    [self.addShowModal setFrame:CGRectMake(self.addShowModal.frame.origin.x, self.addShowModal.frame.origin.y,
                                           self.addShowModal.frame.size.width, 116+20) display:NO animate:YES];
    
    [NSApp beginSheet:self.addShowModal
       modalForWindow:self
        modalDelegate:self
       didEndSelector:@selector(saveSheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (void)saveSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    if(returnCode == NSOKButton)
    {
        NSURL *url = [NSURL URLWithString:self.addShowModal.urlField.stringValue];
        [self addShowURL:url];
    }
    else if(returnCode == NSCancelButton)
    {
    }
    
    [sheet close];
}

- (IBAction)importOPML:(id)sender
{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowedFileTypes:[NSArray arrayWithObjects:@"opml", @"xml", nil]];
    [openDlg setAllowsMultipleSelection:NO];
    
    [openDlg beginSheetModalForWindow:self completionHandler:^(NSInteger result)
    {
        if(result == NSFileHandlingPanelCancelButton)
            return;
        
        NSURL *url = [[openDlg URLs] lastObject];
        NSString *opmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *opml = [XMLReader dictionaryForXMLString:opmlString error:nil];
        NSArray *opmlBody = [[[opml objectForKey:@"opml"] objectForKey:@"body"] objectForKey:@"outline"];
        
        for(NSDictionary *item in opmlBody)
            [self recurseOPMLItem:item];
    }];
}
- (void)recurseOPMLItem:(NSDictionary*)item
{
    if([item objectForKey:@"outline"])
    {
        if([[item objectForKey:@"outline"] isKindOfClass:NSDictionary.class])
            [self recurseOPMLItem:[item objectForKey:@"outline"]];
        else if([[item objectForKey:@"outline"] isKindOfClass:NSArray.class])
            for(NSDictionary *subitem in [item objectForKey:@"outline"])
                [self recurseOPMLItem:subitem];
    }
    else if([item objectForKey:@"xmlUrl"])
    {
        NSURL *url = [NSURL URLWithString:[item objectForKey:@"xmlUrl"]];
        [self addShowURL:url];
    }
}

#pragma mark - Edit List

- (void)addShowURL:(NSURL*)url
{
    NCAppDelegate *delegate = [NSApp delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSTreeNode *node = [self.showsList itemAtRow:self.showsList.selectedRow];
    Group *group = nil;
    NSError *error;
    
    if([node.representedObject isKindOfClass:Group.class] && ![node.representedObject isKindOfClass:StaticGroup.class])
    {
        group = node.representedObject;
    }
    else if([node.representedObject isKindOfClass:Item.class]
            && ![[node.representedObject group] isKindOfClass:StaticGroup.class])
    {
        Item *item = node.representedObject;
        group = item.group;
    }
    else
    {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSArray *groups = [context executeFetchRequest:request error:&error];
        
        if(groups == nil || groups.count == 0)
        {
            group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
            group.title = @"SHOWS";
        }
        else
        {
            for(Group *tempGroup in groups)
            {
                if(![tempGroup isKindOfClass:StaticGroup.class])
                {
                    group = tempGroup;
                    break;
                }
            }
            
            if(!group)
            {
                group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
                group.title = @"SHOWS";
            }
        }
    }
    
    Show *show = [NSEntityDescription insertNewObjectForEntityForName:@"Show" inManagedObjectContext:context];
    {
        [show setTitle:url.absoluteString];
        [show setSubtitle:@""];
        [show setGroup:group];
        
        Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:context];
        {
            [feed setUrl:url.absoluteString];
            [feed setType:[NSNumber numberWithInt:FeedTypePodcast]];
            [feed setShow:show];
        }
        [show addFeedsObject:feed];
    }
    [group addItemsObject:show];
    
    if(![context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    
    [show reload];
    [self.showsList expandItem:nil expandChildren:YES];
}

- (IBAction)removeShowOrGroup:(id)sender
{
    // And Are You Sure? would be nice.
    
    NCAppDelegate *delegate = [NSApp delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSInteger row = (self.showsList.clickedRow != -1) ? self.showsList.clickedRow : self.showsList.selectedRow;
    NSTreeNode *node = [self.showsList itemAtRow:row];
    NSManagedObject *object = node.representedObject;
    
    if([object isKindOfClass:WatchBox.class])
        return;
    else if([object isKindOfClass:StaticGroup.class])
        return;
    
    if([object isKindOfClass:Group.class] || [object isKindOfClass:Item.class])
    {
        [context deleteObject:object];
        
        if([object isKindOfClass:Item.class])
            if(node.parentNode.childNodes.count <= 1)
                [context deleteObject:node.parentNode.representedObject];
        
        [context save:nil];
    }
}

- (IBAction)refreshShowOrGroup:(id)sender
{
    NSInteger row = (self.showsList.clickedRow != -1) ? self.showsList.clickedRow : self.showsList.selectedRow;
    NSTreeNode *node = [self.showsList itemAtRow:row];
    NSManagedObject *object = node.representedObject;
    
    if([object isKindOfClass:Show.class])
    {
        Show *show = (Show*)object;
        [show reload];
    }
}

- (IBAction)renameShowOrGroup:(id)sender
{
    NSInteger row = (self.showsList.clickedRow != -1) ? self.showsList.clickedRow : self.showsList.selectedRow;
    NSTableRowView *view = [self.showsList rowViewAtRow:row makeIfNecessary:NO];
    NSTableCellView *cell = [view viewAtColumn:0];
    [cell.textField becomeFirstResponder];
}

- (IBAction)markWatchedShowOrGroup:(id)sender
{
    NSInteger row = (self.showsList.clickedRow != -1) ? self.showsList.clickedRow : self.showsList.selectedRow;
    NSTreeNode *node = [self.showsList itemAtRow:row];
    NSManagedObject *object = node.representedObject;
    
    if([object isKindOfClass:Show.class])
    {
        Show *show = (Show*)object;
        [show markAllWatched];
    }
}

- (IBAction)refreshAll:(id)sender
{
    NCAppDelegate *delegate = [NSApp delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Show" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSArray *shows = [context executeFetchRequest:request error:nil];
    
    for(Show *show in shows)
        [show reload];
}

#pragma mark - Titlebar Actions

- (IBAction)showShowInfo:(id)sender
{
    if(!self.showInfoPopover.shown)
        [self.showInfoPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
    else
        [self.showInfoPopover close];
}

- (IBAction)showAllEpisodes:(NSSegmentedControl*)sender
{
    if(sender.selectedSegment == 1)
    {
        [self.recentEpisodesView removeFromSuperview];
        
        self.allEpisodesView.frame = self.detailView.bounds;
        self.allEpisodesView.autoresizingMask = 63;
        [self.detailView addSubview:self.allEpisodesView];
    }
    else
    {
        [self.allEpisodesView removeFromSuperview];
        
        self.recentEpisodesView.frame = self.detailView.bounds;
        self.recentEpisodesView.autoresizingMask = 63;
        [self.detailView addSubview:self.recentEpisodesView];
        
    }
}

#pragma mark WindowDelegate

- (void)windowDidResize:(NSNotification*)notification
{
    for(NSView *view in self.recentEpisodesView.subviews)
        if([view.subviews.lastObject isKindOfClass:NSTableView.class])
            [(NSTableView*)view.subviews.lastObject reloadData];
}

#pragma mark TableViewDelegate

- (CGFloat)tableView:(NSTableView*)tableView heightOfRow:(NSInteger)row
{
    float height = (tableView.visibleRect.size.height/tableView.numberOfRows > 200)
    ? tableView.visibleRect.size.height/tableView.numberOfRows-2:200;
    
    return height;
}

@end
