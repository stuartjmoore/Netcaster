//
//  NCAddModal.m
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCAddModal.h"

@implementation NCAddModal

- (IBAction)addURL:(id)sender
{
    [NSApp endSheet:self returnCode:NSOKButton];
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:self returnCode:NSCancelButton];
}

@end
