//
//  NCSourceList.m
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCAppDelegate.h"
#import "NCSourceList.h"
#import "NCEpisodesList.h"

#import "StaticGroup.h"
#import "WatchBox.h"
#import "Group.h"
#import "Item.h"
#import "Show.h"
#import "Feed.h"

@implementation NCSourceList

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self.outlineView registerForDraggedTypes:[NSArray arrayWithObject:@"outlineviewcontroller.Item"]];
}

#pragma mark - Layout

- (BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
    if([((NSTreeNode*)item).representedObject isKindOfClass:Group.class])
        return YES;
    else
        return NO;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView shouldSelectItem:(id)item
{
    if([((NSTreeNode*)item).representedObject isKindOfClass:Group.class])
        return NO;
    else
        return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item
{
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
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
            [show reload];
            
            self.episodesController.show = show;
            [self.episodesController reloadTable];
        }
	}
}

#pragma mark Dragging

- (id<NSPasteboardWriting>)outlineView:(NSOutlineView*)pOutlineView pasteboardWriterForItem:(NSTreeNode*)pItem
{
    id propertyList = [NSNumber numberWithBool:YES];
	return [[NSPasteboardItem alloc] initWithPasteboardPropertyList:propertyList ofType:@"outlineviewcontroller.Item"];
}

- (void)outlineView:(NSOutlineView*)outlineView draggingSession:(NSDraggingSession*)draggingSession willBeginAtPoint:(NSPoint)point forItems:(NSArray*)draggedItems
{
	self.draggingSession = draggingSession;
	self.draggingItem = draggedItems.lastObject;
	self.draggingObject = self.draggingItem.representedObject;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedItem:(NSTreeNode*)item proposedChildIndex:(NSInteger)index
{
	id draggingDest = item.representedObject;
    
	if(draggingInfo.draggingSource == self.outlineView)
    {
        if([self.draggingObject isKindOfClass:WatchBox.class])
            return NSDragOperationNone;
        else if([self.draggingObject isKindOfClass:StaticGroup.class])
            return NSDragOperationNone;
        
        if([draggingDest isKindOfClass:StaticGroup.class])
            return NSDragOperationNone;
        
        if([self.draggingObject isKindOfClass:Item.class] && [draggingDest isKindOfClass:Group.class])
            return NSDragOperationMove;
        else if([self.draggingObject isKindOfClass:Item.class] && !draggingDest)
            return NSDragOperationMove;
        else if([self.draggingObject isKindOfClass:Group.class] && !draggingDest)
            return NSDragOperationMove;
	}
	
	return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)draggingInfo item:(NSTreeNode*)item childIndex:(NSInteger)childIndex
{
    NCAppDelegate *delegate = [NSApp delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
	NSInteger index = (childIndex == NSOutlineViewDropOnItemIndex) ? 0 : childIndex;
	
	if(draggingInfo.draggingSource == self.outlineView)
    {
        if([self.draggingObject isKindOfClass:Item.class])
        {
            NSTreeNode *fromGroup = self.draggingItem.parentNode;
            
            if(item == nil)
            {
                Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
                [group setTitle:@"NEW GROUP"];
                [context save:nil];
                
                item = [self.outlineView itemAtRow:self.outlineView.numberOfRows-1];
            }
            
            [self moveNode:self.draggingItem toIndexPath:[item.indexPath indexPathByAddingIndex:index]];
            [self.outlineView expandItem:item];
            
            if(fromGroup.childNodes.count <= 0)
                [context deleteObject:fromGroup.representedObject];
        }
        else if([self.draggingObject isKindOfClass:Group.class])
        {
			[self moveNode:self.draggingItem toIndexPath:[NSIndexPath indexPathWithIndex:index]];
        }
        
		return YES;
	}
	
	return NO;
}

- (void)outlineView:(NSOutlineView*)outlineView draggingSession:(NSDraggingSession*)draggingSession endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	self.draggingItem = nil;
	self.draggingSession = nil;
	self.draggingObject = nil;
}

- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item
{
    return nil;
}

@end
