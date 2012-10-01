//
//  NCAppDelegate.h
//  Netcaster
//
//  Created by Stuart Moore on 9/29/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSOutlineView *showsList;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
