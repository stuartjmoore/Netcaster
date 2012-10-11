//
//  Episode.m
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "Episode.h"
#import "Enclosure.h"
#import "Show.h"

@implementation Episode

@dynamic aired;
@dynamic cast;
@dynamic desc;
@dynamic descShort;
@dynamic duration;
@dynamic expires;
@dynamic image;
@dynamic isNew;
@dynamic number;
@dynamic published;
@dynamic timecode;
@dynamic title;
@dynamic unwatched;
@dynamic website;
@dynamic enclosures;
@dynamic price, currency, rating;
@dynamic show;

#pragma mark - Transformers

- (NSImage*)imageValue
{
    if(self.image && self.image.length > 0)
        return [[NSImage alloc] initWithData:self.image];
    else
        return [[NSImage alloc] initWithData:self.show.image];
    
    // else default image
}

- (NSAttributedString*)descAttr
{
    NSData *data = [self.desc dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSAttributedString alloc] initWithHTML:data documentAttributes:nil];
}

#pragma mark - Selectors


- (void)watchNow:(NSTableCellView*)sender
{
    Enclosure *enclosure = self.enclosures.anyObject; //Single feeds for now
    NSURL *url = [NSURL URLWithString:enclosure.url];
    
    if([enclosure.type isEqualToString:@"webpage/hulu"]
    || [enclosure.type isEqualToString:@"webpage/youtube"]
    || [enclosure.type isEqualToString:@"text/html"])
    {
        [NSWorkspace.sharedWorkspace openURL:url];
    }
    else
    {
        if([NSWorkspace.sharedWorkspace absolutePathForAppBundleWithIdentifier:@"com.apple.QuickTimePlayerX"])
        {
            [NSWorkspace.sharedWorkspace openURLs:[NSArray arrayWithObject:url]
                          withAppBundleIdentifier:@"com.apple.QuickTimePlayerX"
                                          options:NSWorkspaceLaunchAsync
                   additionalEventParamDescriptor:nil
                                launchIdentifiers:nil];
        }
        /*
         [NSWorkspace.sharedWorkspace openURLs:[NSArray arrayWithObject:url]
         withAppBundleIdentifier:@"org.videolan.vlc"
         options:NSWorkspaceLaunchAsync
         additionalEventParamDescriptor:nil
         launchIdentifiers:nil];
         */
    }
}

- (void)markUnwatched:(NSTableCellView*)sender
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5f];
    [sender.animator setAlphaValue:0];
    [self performSelector:@selector(finishMarkUnwatched:) withObject:sender afterDelay:0.5f];
    [NSAnimationContext endGrouping];
    
    /*
    for(NSView *subview in sender.subviews)
    {
        if([subview isKindOfClass:NSButton.class])
        {
            NSButton *button = (NSButton*)subview;
            if([button.title isEqualToString:@"Mark Watched"])
            {
                button.title = @"Undo";
                [self performSelector:@selector(fadeOutView:) withObject:button afterDelay:0.5f];
                continue;
            }
        }
        
        [subview.animator setAlphaValue:0];
    }
    */
}
- (void)finishMarkUnwatched:(NSTableCellView*)sender
{    
    [self.show willChangeValueForKey:@"unwatchedEpisodes"];
    
    self.unwatched = [NSNumber numberWithBool:NO];
    
    self.show.unwatchedCount = [NSNumber numberWithInt:(self.show.unwatchedCount.intValue-1)];
    
    if(self.show.unwatchedCount.intValue < 0)
        self.show.unwatchedCount = [NSNumber numberWithInt:0];

    self.show.subtitle = [NSString stringWithFormat:@"%d", self.show.unwatchedCount.intValue];
    
    [sender setAlphaValue:1];
    
    [self.show didChangeValueForKey:@"unwatchedEpisodes"];
}

@end
