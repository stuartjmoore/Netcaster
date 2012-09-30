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
    if (self)
    {
        /*NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShowInfo"
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError *error;
         NSArray *failedBankInfos = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        NSLog(@"%@", failedBankInfos);*/
    }
    return self;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return NO;
}

- (NSView *)outlineView:(NSOutlineView*)outlineView viewForTableColumn:(NSTableColumn*)tableColumn item:(id)item
{
    NSTableCellView *view = nil;
    NSTreeNode *node = item;
    
   // NSLog(@"%@", node.representedObject);
    
    if([node.representedObject isKindOfClass:Group.class])
    {
        view = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
    }
    else
    {
        view = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
    }
    
    return view;
}

@end
