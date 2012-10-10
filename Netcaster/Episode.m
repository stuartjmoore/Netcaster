//
//  Episode.m
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCEpisodesList.h"

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

- (NSImage*)imageValue
{
    if(self.image)
        return [[NSImage alloc] initWithData:self.image];
    else
        return [[NSImage alloc] initWithData:self.show.image];
}

- (void)markUnwatched
{
    [self.show willChangeValueForKey:@"unwatchedEpisodes"];
    
    self.unwatched = [NSNumber numberWithBool:NO];
    
    self.show.unwatchedCount = [NSNumber numberWithInt:(self.show.unwatchedCount.intValue-1)];
    self.show.subtitle = [NSString stringWithFormat:@"%d", self.show.unwatchedCount.intValue];
    
    [self.show didChangeValueForKey:@"unwatchedEpisodes"];
}

- (void)watchNow
{
    Enclosure *enclosure = self.enclosures.anyObject; //Single feeds for now
    NSURL *url = [NSURL URLWithString:enclosure.url];
    
    if([enclosure.type isEqualToString:@"webpage/hulu"] || [enclosure.type isEqualToString:@"webpage/youtube"])
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

@end
