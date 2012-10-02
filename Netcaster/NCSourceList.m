//
//  NCSourceList.m
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCSourceList.h"
#import "NCEpisodesList.h"

#import "Group.h"
#import "Item.h"
#import "Show.h"
#import "Feed.h"

@implementation NCSourceList

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
            
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO];
            NSArray *descriptors = [NSArray arrayWithObject:descriptor];
            NSArray *sortedEpisodes = [show.episodes sortedArrayUsingDescriptors:descriptors];
            self.episodesController.episodes = sortedEpisodes;
            
            [self.episodesTable reloadData];
        }
	}
}

/*
#pragma mark - Autosave

- (id)outlineView:(NSOutlineView *)outlineView itemForPersistentObject:(id)object
{
    // Iterate all the items. This is not straightforward because the outline
    // view items are nested. So you cannot just iterate the rows. Rows
    // correspond to root nodes only. The outline view interface does not
    // provide any means to query the hidden children within each collapsed row
    // either. However, the root nodes do respond to -childNodes. That makes it
    // possible to walk the tree.
    NSMutableArray *items = [NSMutableArray array];
    NSInteger i, rows = [outlineView numberOfRows];
    for (i = 0; i < rows; i++)
    {
        [items addObject:[outlineView itemAtRow:i]];
    }
    for (i = 0; i < [items count] && ![object isEqualToString:[[[[[items objectAtIndex:i] representedObject] objectID] URIRepresentation] absoluteString]]; i++)
    {
        [items addObjectsFromArray:[[items objectAtIndex:i] childNodes]];
    }
    return i < [items count] ? [items objectAtIndex:i] : nil;
}

- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item
{
    // "Persistent object" means a unique representation of the item's object,
    // representing the objects identity, not its state. Outline view writes
    // this to user defaults as soon as the item expands. That's when it asks
    // for the persistent object, sending -outlineView:persistentObjectForItem:
    // and execution arrives here. A minor problem arises when adding new
    // items. The new item represents a new unsaved managed object. The managed
    // object only has a temporary object identifier. It will receive a
    // permanent one when saved. So, if the objectID answers a temporary one,
    // ask the context to save and re-request the objectID. The second request
    // gives a permanent identifier, assuming saving succeeds. Don't worry about
    // committing unsaved edits at this point.
    NSManagedObject *object = [item representedObject];
    NSManagedObjectID *objectID = [object objectID];
    if ([objectID isTemporaryID])
    {
        if (![[object managedObjectContext] save:NULL])
        {
            return nil;
        }
        objectID = [object objectID];
    }
    return [[objectID URIRepresentation] absoluteString];
}
*/
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
