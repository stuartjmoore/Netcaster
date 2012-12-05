//
//  NCAppDelegate.m
//  Netcaster
//
//  Created by Stuart Moore on 9/29/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCAppDelegate.h"
#import "XMLReader.h"

#import "NCWindow.h"
#import "NCAddModal.h"

#import "StaticGroup.h"
#import "WatchBox.h"
#import "Episode.h"
#import "Enclosure.h"

#define MAX_EPISODES 50

@implementation NCAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationWillFinishLaunching:(NSNotification*)notification
{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass
                            andEventID:kAEGetURL];
    
    CFStringRef bundleID = (__bridge CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
    LSSetDefaultHandlerForURLScheme(CFSTR("pcast"), bundleID);
}
/*
 - (BOOL)application:(NSApplication*)application openFile:(NSString*)filename
 {
 NSURL *url = [NSURL fileURLWithPath:filename];
 NSLog(@"%@", url);
 
 return NO;
 }
 */
- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"WatchBox" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSArray *watchBoxes = [context executeFetchRequest:request error:nil];
    
    if(watchBoxes == nil || watchBoxes.count == 0)
    {
        StaticGroup *staticGroup = [NSEntityDescription insertNewObjectForEntityForName:@"StaticGroup" inManagedObjectContext:context];
        staticGroup.title = @"NETCASTER";
        WatchBox *watchBox = [NSEntityDescription insertNewObjectForEntityForName:@"WatchBox" inManagedObjectContext:context];
        watchBox.title = @"Watch Box";
        watchBox.desc = @"";
        watchBox.image = nil;
        watchBox.group = staticGroup;
        [staticGroup addItemsObject:watchBox];
        [context save:nil];
    }
    
    [self.showsList setAutosaveExpandedItems:YES];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    
    if([url hasPrefix:@"pcast://"])
    {
        url = [url stringByReplacingOccurrencesOfString:@"pcast://" withString:@"http://"];
    
        [self.window dispalyAddNewShowModal:nil];
        self.addShowModal.urlField.stringValue = url;
        [self.addShowModal controlTextDidChange:nil];
    }
    else
    {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            if(error)
                return;
            
            NSString *html = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSScanner *scanner = [NSScanner scannerWithString:html];
            
            NSString *title = @"", *desc = @"", *image = @"";
            
            while(scanner.isAtEnd == NO)
            {
                NSString *text = nil;
                
                [scanner scanUpToString:@"<" intoString:NULL];
                [scanner scanUpToString:@">" intoString:&text];
                text = [text stringByAppendingString:@">"];
                /*
                [scanner scanUpToString:@"<" intoString:nil];
                [scanner scanString:@"<" intoString:nil];
                [scanner scanUpToString:@">" intoString:&stringBetweenBrackets];
                */
                if([text hasPrefix:@"<meta property=\"og:title\""]
                || [text hasPrefix:@"<meta name=\"og:title\""])
                {
                    NSUInteger location = [text rangeOfString:@"content=\""].location + 9;
                    NSUInteger length = [text rangeOfString:@"\"" options:NSBackwardsSearch].location;
                    
                    title = [text substringWithRange:NSMakeRange(location, length-location)];
                }
                else if([text hasPrefix:@"<meta property=\"og:description\""]
                     || [text hasPrefix:@"<meta name=\"og:description\""])
                {
                    NSUInteger location = [text rangeOfString:@"content=\""].location + 9;
                    NSUInteger length = [text rangeOfString:@"\"" options:NSBackwardsSearch].location;
                    
                    desc = [text substringWithRange:NSMakeRange(location, length-location)];
                    
                }
                else if([text hasPrefix:@"<meta property=\"og:image\""]
                     || [text hasPrefix:@"<meta name=\"og:image\""])
                {
                    NSUInteger location = [text rangeOfString:@"content=\""].location + 9;
                    NSUInteger length = [text rangeOfString:@"\"" options:NSBackwardsSearch].location;
                    
                    image = [text substringWithRange:NSMakeRange(location, length-location)];
                }
            }
            
            
            NSManagedObjectContext *context = [self managedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"WatchBox"
                                                                 inManagedObjectContext:context];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            NSArray *watchBoxes = [context executeFetchRequest:request error:nil];
            WatchBox *watchBox = watchBoxes.lastObject;
            
            while(watchBox.episodes.count >= MAX_EPISODES)
            {
                NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO];
                NSArray *descriptors = [NSArray arrayWithObject:descriptor];
                NSArray *sortedEpisodes = [watchBox.episodes sortedArrayUsingDescriptors:descriptors];
                Episode *oldestEpisode = sortedEpisodes.lastObject;

                [watchBox removeEpisodesObject:oldestEpisode];
            }
            
            [watchBox willChangeValueForKey:@"unwatchedEpisodes"];
            Episode *episode = [NSEntityDescription insertNewObjectForEntityForName:@"Episode"
                                                             inManagedObjectContext:context];
            episode.title = title;
            episode.desc = desc;
            episode.descShort = desc;
            episode.website = url;
            episode.published = [NSDate date];
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:image]];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
            {
                [episode willChangeValueForKey:@"imageValue"];
                episode.image = data;
                [episode didChangeValueForKey:@"imageValue"];
            }];
            
            Enclosure *enclosure = [NSEntityDescription insertNewObjectForEntityForName:@"Enclosure"
                                                                 inManagedObjectContext:context];
            enclosure.episode = episode;
            enclosure.url = url;
            enclosure.type = @"text/html";
            [episode addEnclosuresObject:enclosure];
            
            episode.show = watchBox;
            [watchBox addEpisodesObject:episode];
            watchBox.unwatchedCount = [NSNumber numberWithInt:(watchBox.unwatchedCount.intValue+1)];
            
            [context save:nil];
            [watchBox didChangeValueForKey:@"unwatchedEpisodes"];
            
            [self.showsList selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
            [self.window makeKeyAndOrderFront:self];
        }];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)application hasVisibleWindows:(BOOL)flag
{
    if(!flag)
        [self.window makeKeyAndOrderFront:self];
    
    return YES;
}

#pragma mark - Core Data

- (NSArray*)treeNodeSortDescriptors;
{
	return [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES]];
}

#pragma mark Generated

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.stuartjmoore.Netcaster" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.stuartjmoore.Netcaster"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Netcaster" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Netcaster.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
