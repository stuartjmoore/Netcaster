//
//  NCWindow.h
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NCWindow : NSWindow

@property (nonatomic, weak) IBOutlet NSWindow *addShowModal;

- (IBAction)addNewShow:(id)sender;

@end
