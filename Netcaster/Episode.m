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
    //else
        //return default image
}

- (NSString*)displayTitle
{
    NSString *title = self.title;
    
    title = [title stringByReplacingOccurrencesOfString:self.show.title withString:@""];
    
    while([title rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location == 0
       || [title rangeOfCharacterFromSet:[NSCharacterSet symbolCharacterSet]].location == 0
       || [title rangeOfString:@"#"].location == 0
       || [title rangeOfString:@","].location == 0
       || [title rangeOfString:@":"].location == 0
       || [title rangeOfString:@"-"].location == 0
       || [title rangeOfString:@"."].location == 0
       || [title rangeOfString:@"/"].location == 0
       || [title rangeOfString:@"Episode"].location == 0
       || [title rangeOfString:@"episode"].location == 0
       || [title rangeOfString:@"ep"].location == 0
       || [title rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == 0)
    {
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(title.length >= 7)
            title = [title stringByReplacingOccurrencesOfString:@"Episode" withString:@"" options:0 range:NSMakeRange(0, 7)];
        if(title.length >= 7)
            title = [title stringByReplacingOccurrencesOfString:@"episode" withString:@"" options:0 range:NSMakeRange(0, 7)];
        if(title.length >= 2)
            title = [title stringByReplacingOccurrencesOfString:@"ep" withString:@"" options:0 range:NSMakeRange(0, 2)];
        
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    }
    
    if([title isEqualToString:@""])
        return self.title;
    
    return title;
}

- (NSAttributedString*)descAttr
{
    NSData *data = [self.desc dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSAttributedString alloc] initWithHTML:data documentAttributes:nil];
}

- (NSString*)publishedString
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setTimeStyle:NSDateFormatterNoStyle];
    [format setDateStyle:NSDateFormatterMediumStyle];
    
    return [format stringFromDate:self.published];
}

- (NSString*)durationString
{
    if(self.duration.intValue == 0)
        return @"";
    
    int hrUntil = 0;
    int minUntil = self.duration.intValue/60;
    
    while(minUntil >= 60)
    {
        hrUntil++;
        minUntil -= 60;
    }

    return [NSString stringWithFormat:@"%d:%0.2d:%0.2d", hrUntil, minUntil, self.duration.intValue%60];
}

- (NSString*)watchButtonTitle
{
    Enclosure *enclosure = self.enclosures.anyObject; //Single feeds for now
    
    if([enclosure.type isEqualToString:@"audio/mpeg"])
        return @"Listen";
    else if([enclosure.type isEqualToString:@"webpage/hulu"]
    || [enclosure.type isEqualToString:@"webpage/youtube"]
    || [enclosure.type isEqualToString:@"text/html"])
        return @"Open";
    else
        return @"Watch";
}

#pragma mark - Selectors

- (void)watchNow:(id)sender
{
    Enclosure *enclosure = self.enclosures.anyObject; //Single feeds for now
    NSURL *url = [NSURL URLWithString:enclosure.url];
    
    if([enclosure.type isEqualToString:@"webpage/hulu"]
    || [enclosure.type isEqualToString:@"webpage/youtube"]
    || [enclosure.type isEqualToString:@"text/html"])
    {
        [NSWorkspace.sharedWorkspace openURL:url];
    }
    else if([enclosure.type isEqualToString:@"audio/mpeg"])
    {
        if([NSWorkspace.sharedWorkspace absolutePathForAppBundleWithIdentifier:@"com.stuartjmoore.PlayBar"])
        {
            [NSWorkspace.sharedWorkspace openURLs:[NSArray arrayWithObject:url]
                          withAppBundleIdentifier:@"com.stuartjmoore.PlayBar"
                                          options:NSWorkspaceLaunchAsync
                   additionalEventParamDescriptor:nil
                                launchIdentifiers:nil];
        }
        else if([NSWorkspace.sharedWorkspace absolutePathForAppBundleWithIdentifier:@"com.apple.QuickTimePlayerX"])
        {
            [NSWorkspace.sharedWorkspace openURLs:[NSArray arrayWithObject:url]
                          withAppBundleIdentifier:@"com.apple.QuickTimePlayerX"
                                          options:NSWorkspaceLaunchAsync
                   additionalEventParamDescriptor:nil
                                launchIdentifiers:nil];
        }
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

- (void)toggleWatched:(id)sender
{
    [self.show willChangeValueForKey:@"unwatchedEpisodes"];
    
    self.unwatched = [NSNumber numberWithBool:!self.unwatched.boolValue];
    
    if(self.unwatched.boolValue)
    {
        self.show.unwatchedCount = [NSNumber numberWithInt:(self.show.unwatchedCount.intValue+1)];
    }
    else
    {
        if(self.show.unwatchedCount.intValue-1 > 0)
            self.show.unwatchedCount = [NSNumber numberWithInt:(self.show.unwatchedCount.intValue-1)];
        else
            self.show.unwatchedCount = [NSNumber numberWithInt:0];
    }
        
    [self.show didChangeValueForKey:@"unwatchedEpisodes"];
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
    
    if(self.show.unwatchedCount.intValue-1 > 0)
        self.show.unwatchedCount = [NSNumber numberWithInt:(self.show.unwatchedCount.intValue-1)];
    else
        self.show.unwatchedCount = [NSNumber numberWithInt:0];
    
    [sender setAlphaValue:1];
    
    [self.show didChangeValueForKey:@"unwatchedEpisodes"];
}

@end
