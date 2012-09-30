//
//  NCShowsList.m
//  Netcaster
//
//  Created by Stuart Moore on 9/29/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCShowsList.h"

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

- (void)outlineViewSelectionDidChange:(NSNotification*)aNotification
{
	NSTreeNode *item = [self itemAtRow:self.selectedRow];
    
	if(![item.representedObject isKindOfClass:Group.class])
	{
        NSLog(@"Selected");
	}
}

@end
