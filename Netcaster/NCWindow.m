//
//  NCWindow.m
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCWindow.h"
#import "NCAppDelegate.h"

@implementation NCWindow

#pragma mark - Menu bar Actions

- (IBAction)addNewShow:(id)sender
{
    [NSApp beginSheet:self.addShowModal modalForWindow:self modalDelegate:self
       didEndSelector:@selector(saveSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)saveSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    if (returnCode == NSOKButton)
    {
        NCAppDelegate *delegate = [NSApp delegate];
        
        NSManagedObjectContext *context = [delegate managedObjectContext];
        
        NSManagedObject *group = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"Group"
                                  inManagedObjectContext:context];
        [group setValue:@"Test Group" forKey:@"title"];
        
        NSManagedObject *show = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"Item"
                                 inManagedObjectContext:context];
        [show setValue:@"Test Show" forKey:@"title"];
        [show setValue:group forKey:@"group"];
        
        [group setValue:[NSSet setWithObject:show] forKey:@"items"];
        
        
        NSError *error;
        if(![context save:&error])
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    else if (returnCode == NSCancelButton)
    {
    }
    
    [sheet close];
}

@end
