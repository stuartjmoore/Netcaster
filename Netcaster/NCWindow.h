//
//  NCWindow.h
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NCShowsList, NCAddModal;

@interface NCWindow : NSWindow

@property (nonatomic, weak) IBOutlet NCAddModal *addShowModal;
@property (nonatomic, weak) IBOutlet NCShowsList *showsList;

- (IBAction)addNewShow:(id)sender;
- (IBAction)removeShowOrGroup:(id)sender;

@end
