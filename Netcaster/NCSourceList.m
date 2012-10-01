//
//  NCSourceList.m
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCSourceList.h"
#import "Group.h"
#import "Item.h"
#import "Show.h"
#import "Feed.h"

@implementation NCSourceList

#pragma mark - Layout

- (BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
    return NO;
}

- (NSView *)outlineView:(NSOutlineView*)outlineView viewForTableColumn:(NSTableColumn*)column item:(id)item
{
    if([((NSTreeNode*)item).representedObject isKindOfClass:Group.class])
        return [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
    else
        return [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
}

#pragma mark - Selection

- (void)outlineViewSelectionDidChange:(NSNotification*)notification
{
    NSOutlineView *list = notification.object;
	NSTreeNode *node = [list itemAtRow:list.selectedRow];
    
	if([node.representedObject isKindOfClass:Item.class])
	{
        Item *item = node.representedObject;
        
        if([item isKindOfClass:Show.class])
        {
            Show *show = (Show*)item;
            NSSet *feeds = show.feeds;
            Feed *feed = feeds.anyObject;
            
            NSLog(@"%@", feed.url);
        }
	}
}
/*
#pragma mark - Drag and Drop

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pasteboard
{
    //NSString *pasteBoardType = [self pasteboardTypeForTableView:outlineView];
    //[pboard declareTypes:[NSArray arrayWithObject:pasteBoardType] owner:self];
    
    //NSData *rowData = [NSKeyedArchiver archivedDataWithRootObject:items];
    //[pboard setData:rowData forType:pasteBoardType];
    
    NSLog(@"writeItems");
    
    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];
	[pasteboard declareTypes:[NSArray arrayWithObject:@"ItemsDropType"] owner:self];
	[pasteboard setData:[NSData data] forType:@"ItemsDropType"];
    
    //[outlineView setDropItem:nil dropChildIndex:0];
    
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    NSLog(@"validateDrop");
    return NSDragOperationMove;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index
{
    NSLog(@"acceptDrop");
    return YES;
}
*/

@end
