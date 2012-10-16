//
//  NCSourceItemCell.m
//  Netcaster
//
//  Created by Stuart Moore on 10/16/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCSourceItemCell.h"
#import "Show.h"

@implementation NCSourceItemCell
- (void)drawRect:(NSRect)dirtyRect
{
    if (self.backgroundStyle == NSBackgroundStyleDark)
    {
        self.subtitleField.textColor = [NSColor whiteColor];
        self.subtitleField.font = [NSFont boldSystemFontOfSize:11];
    }
    else if(self.backgroundStyle == NSBackgroundStyleLight)
    {
        Show *show = self.objectValue;
        
        if(show.hasNew.boolValue)
        {
            self.subtitleField.textColor = [NSColor colorWithCalibratedRed:0.82 green:0.15 blue:0.08 alpha:1.0];
            self.subtitleField.font = [NSFont boldSystemFontOfSize:11];
        }
        else
        {
            self.subtitleField.textColor = [NSColor colorWithCalibratedRed:0.44 green:0.49 blue:0.55 alpha:1.0];
            self.subtitleField.font = [NSFont systemFontOfSize:11];
        }
    }
}


@end
