//
//  NCShowsList.m
//  Netcaster
//
//  Created by Stuart Moore on 9/29/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCShowsList.h"
#import "Item.h"

@implementation NCShowsList

@synthesize managedObjectContext;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
    }
    return self;
}

#pragma mark - Layout

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return NO;
}

- (NSView *)outlineView:(NSOutlineView*)outlineView viewForTableColumn:(NSTableColumn*)tableColumn item:(id)item
{
    if([((NSTreeNode*)item).representedObject isKindOfClass:Group.class])
        return [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
    else
        return [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
}

#pragma mark - Selection

- (void)outlineViewSelectionDidChange:(NSNotification*)notification
{
    NCShowsList *list = notification.object;
	NSTreeNode *node = [list itemAtRow:list.selectedRow];
    
	if([node.representedObject isKindOfClass:Item.class])
	{
        Item *item = node.representedObject;
        
        if([[item valueForKey:@"Type"] intValue] == ItemTypeShow)
        {
            Show *show = [item valueForKey:@"Show"];
            NSLog(@"%@",show);
        }
	}
}

@end
