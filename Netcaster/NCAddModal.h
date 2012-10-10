//
//  NCAddModal.h
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NCAddModal : NSWindow <NSTextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *urlField;
@property (nonatomic, weak) IBOutlet NSView *detailField;
@property (nonatomic, weak) IBOutlet NSButton *addButton;

@property (nonatomic, weak) IBOutlet NSView *showDetailView;
@property (nonatomic, weak) IBOutlet NSTextField *showDetailTitle, *showDetailDesc;
@property (nonatomic, weak) IBOutlet NSImageView *showDetailImage;

- (IBAction)addURL:(id)sender;
- (IBAction)cancel:(id)sender;

@end