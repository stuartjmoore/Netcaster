//
//  NCWindow.m
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCWindow.h"
#import "NCAppDelegate.h"
#import "NCAddModal.h"
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
        self.showsList.floatsGroupRows = NO;
        [self.showsList registerForDraggedTypes:[NSArray arrayWithObjects:@"ItemsDropType", nil]];
    }
    return self;
}

#pragma mark - Menu bar Actions

- (IBAction)addNewShow:(id)sender
{
    [NSApp beginSheet:self.addShowModal modalForWindow:self modalDelegate:self
       didEndSelector:@selector(saveSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)saveSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    if(returnCode == NSOKButton)
    {
        NCAppDelegate *delegate = [NSApp delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        NSTreeNode *node = [self.showsList itemAtRow:self.showsList.selectedRow];
        Group *group = nil;
        NSError *error;
        
        if([node.representedObject isKindOfClass:Group.class])
        {
            group = node.representedObject;
        }
        else if([node.representedObject isKindOfClass:Item.class])
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
                [group setTitle:@"SHOWS"];
            }
            else
            {
                group = groups.lastObject;
            }
        }
        
        Show *show = [NSEntityDescription insertNewObjectForEntityForName:@"Show" inManagedObjectContext:context];
        {
            [show setTitle:self.addShowModal.urlField.stringValue];
            [show setSubtitle:@"0"];
            [show setGroup:group];
            
            Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:context];
            {
                [feed setUrl:self.addShowModal.urlField.stringValue];
                [feed setType:[NSNumber numberWithInt:FeedTypePodcast]];
                [feed setShow:show];
            }
            [show addFeedsObject:feed];
        }
        [group addItemsObject:show];
        
        if(![context save:&error])
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    else if(returnCode == NSCancelButton)
    {
    }
    
    [sheet close];
}

- (IBAction)removeShowOrGroup:(id)sender
{
    // And Are You Sure? would be nice.
    
    NCAppDelegate *delegate = [NSApp delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSTreeNode *node = [self.showsList itemAtRow:self.showsList.selectedRow];
    
    if([node.representedObject isKindOfClass:Group.class] || [node.representedObject isKindOfClass:Item.class])
    {
        NSManagedObject *object = node.representedObject;
        [context deleteObject:object];
    }
}

@end
