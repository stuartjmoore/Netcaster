//
//  Show.m
//  Netcaster
//
//  Created by Stuart Moore on 10/1/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCAppDelegate.h"
#import "XMLReader.h"

#import "Show.h"
#import "Channel.h"
#import "Episode.h"
#import "Enclosure.h"
#import "Feed.h"

#define MAX_EPISODES 50

@implementation Show

@dynamic cast;
@dynamic channelName; //delete
@dynamic desc;
@dynamic genre;
@dynamic image;
@dynamic isNewCount;
@dynamic schedule;
@dynamic unwatchedCount;
@dynamic website;
@dynamic channel;
@dynamic episodes;
@dynamic feeds;

- (NSArray*)unwatchedEpisodes
{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"published" ascending:YES];
    NSArray *sortedEpisodes = [self.episodes sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unwatched == %@", [NSNumber numberWithBool:YES]];
    return [sortedEpisodes filteredArrayUsingPredicate:predicate];
}

- (void)reload
{
    // http://revision3.com/trs/feed/MP4-hd30
    // http://tfvpodcast.wordpress.com/feed/rss/
    // http://feeds.twit.tv/fr_video_large
    
    // Only one feed is supported right now
    Feed *feed = self.feeds.anyObject;
    
    NSMutableURLRequest *headerRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed.url]
                                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                             timeoutInterval:60.0f];
    [headerRequest setHTTPMethod:@"HEAD"];
    [NSURLConnection sendAsynchronousRequest:headerRequest queue:[NSOperationQueue mainQueue]
    completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
         if([response respondsToSelector:@selector(allHeaderFields)])
         {
             NSDictionary *metaData = [httpResponse allHeaderFields];
             NSString *lastModifiedString = [metaData objectForKey:@"Last-Modified"];
             
             NSDateFormatter *df = [[NSDateFormatter alloc] init];
             df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
             
             NSDate *lastModified = [df dateFromString:lastModifiedString];
             
             if(lastModified == nil || ![lastModified isEqualToDate:feed.updated])
                 [self updatePodcastFeed:feed];
         }
    }];
}

- (void)updatePodcastFeed:(Feed*)feed
{
    // if feed.updated == nil, [NSDate date];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feed.url]];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
    completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if([response respondsToSelector:@selector(allHeaderFields)])
        {
            NSDictionary *metaData = [httpResponse allHeaderFields];
            NSString *lastModifiedString = [metaData objectForKey:@"Last-Modified"];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
            
            feed.updated = [df dateFromString:lastModifiedString];
        }
        
        NCAppDelegate *delegate = [NSApp delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        NSDictionary *RSS = [XMLReader dictionaryForXMLData:data error:nil];
        
        BOOL firstLoad = NO;
        
        if(self.episodes.count == 0)
            firstLoad = YES;
        
        if(!self.desc)
        {
            firstLoad = YES;
            
            NSDictionary *showDic = [[RSS objectForKey:@"rss"] objectForKey:@"channel"];
            
            NSString *title = [XMLReader stringFromDictionary:showDic withKeys:@"title", @"text", nil];
            if(!title) title = @"";
            
            NSString *desc = [XMLReader stringFromDictionary:showDic withKeys:@"description", @"text", nil];
            if(!desc) desc = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:subtitle", @"text", nil];
            if(!desc) desc = @"";
            
            NSString *image = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:image", @"href", nil];
            if(!image) image = @"";
            
            NSString *link = [XMLReader stringFromDictionary:showDic withKeys:@"link", @"text", nil];
            if(!link) link = @"";
            
            NSString *author = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:author", @"text", nil];
            if(!author) author = @"";
            
            NSString *genre = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:category", @"text", nil];
            if(!genre) genre = @"";
            
            
            self.title = title;
            self.desc = desc;
            self.website = link;
            self.genre = genre;
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:image]];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 self.image = data;
             }];
            
            Channel *channel = [NSEntityDescription insertNewObjectForEntityForName:@"Channel" inManagedObjectContext:context];
            channel.title = author;
            [channel addShowsObject:self];
            self.channel = channel;
        }
        
        NSArray *episodes = [[[RSS objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];
        for(NSDictionary *epiDic in episodes)
        {
            NSString *title = [XMLReader stringFromDictionary:epiDic withKeys:@"title", @"text", nil];
            if(!title) title = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"media:title", @"text", nil];
            if(!title) title = @"";
            
            //NSCharacterSet *nonalphanumericSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
            
            NSString *desc = [XMLReader stringFromDictionary:epiDic withKeys:@"content:encoded", @"text", nil];
            if(!desc) desc = [XMLReader stringFromDictionary:epiDic withKeys:@"description", @"text", nil];
            if(!desc) desc = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:summary", @"text", nil];
            if(!desc) desc = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:subtitle", @"text", nil];
            if(!desc) desc = @"";
            
            NSString *descShort = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:summary", @"text", nil];
            if(!descShort) descShort = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:subtitle", @"text", nil];
            if(!descShort) descShort = @"";
            
            NSString *image = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"media:thumbnail", @"url", nil];
            if(!image) image = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:image", @"href", nil];
            if(!image) image = @"";
            
            NSString *pubDateString = [XMLReader stringFromDictionary:epiDic withKeys:@"pubDate", @"text", nil];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
            NSDate *pubDate = [dateFormat dateFromString:pubDateString];
            if(!pubDate) pubDate = [NSDate dateWithTimeIntervalSince1970:0];
            
            NSString *duration = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:duration", @"text", nil];
            if(!duration) duration = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"duration", nil];
            if(!duration) duration = @"";
            
            NSString *link = [XMLReader stringFromDictionary:epiDic withKeys:@"link", @"text", nil];
            if(!link) link = @"";
            
            NSString *enclosureURL = [XMLReader stringFromDictionary:epiDic withKeys:@"enclosure", @"url", nil];
            if(!enclosureURL) enclosureURL = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"url", nil];
            if(!enclosureURL) enclosureURL = @"";
            
            NSString *fileSize = [XMLReader stringFromDictionary:epiDic withKeys:@"enclosure", @"length", nil];
            if(!fileSize) fileSize = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"fileSize", nil];
            if(!fileSize) fileSize = @"";
            
            NSString *fileType = [XMLReader stringFromDictionary:epiDic withKeys:@"enclosure", @"type", nil];
            if(!fileType) fileType = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"type", nil];
            if(!fileType) fileType = @"";
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@ && published == %@", title, pubDate];
            if([[self.episodes filteredSetUsingPredicate:predicate] count] > 0)
            {
                //NSLog(@"%@ exists", title);
                continue;
            }
            
            
            if(self.episodes.count >= MAX_EPISODES)
            {
                NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO];
                NSArray *descriptors = [NSArray arrayWithObject:descriptor];
                NSArray *sortedEpisodes = [self.episodes sortedArrayUsingDescriptors:descriptors];
                Episode *oldestEpisode = sortedEpisodes.lastObject;
                
                if([pubDate laterDate:oldestEpisode.published] == oldestEpisode.published)
                {
                    //NSLog(@"%@ is too old", title);
                    continue;
                }
                else
                {
                    //NSLog(@"%@ is too old", oldestEpisode.title);
                    [context deleteObject:oldestEpisode];
                }
            }
            
            
            Episode *episode = [NSEntityDescription insertNewObjectForEntityForName:@"Episode" inManagedObjectContext:context];
            episode.title = title;
            episode.desc = desc;
            episode.descShort = descShort;
            episode.duration = [NSNumber numberWithInteger:duration.integerValue];
            episode.website = link;
            episode.published = pubDate;
            /*
            if(firstLoad)
            {
                if([episodes indexOfObject:epiDic] == 0)
                {
                    episode.isNew = [NSNumber numberWithBool:YES];
                    episode.unwatched = [NSNumber numberWithBool:YES];
                    self.unwatchedCount = [NSNumber numberWithInt:1];
                    self.subtitle = @"1";
                }
                else
                {
                    episode.isNew = [NSNumber numberWithBool:NO];
                    episode.unwatched = [NSNumber numberWithBool:NO];
                }
            }
            else*/
            {
                episode.isNew = [NSNumber numberWithBool:YES];
                episode.unwatched = [NSNumber numberWithBool:YES];
                self.unwatchedCount = [NSNumber numberWithInt:(self.unwatchedCount.intValue+1)];
                self.subtitle = [NSString stringWithFormat:@"%d", self.unwatchedCount.intValue];
            }
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:image]];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 episode.image = data;
             }];
            
            
            Enclosure *enclosure = [NSEntityDescription insertNewObjectForEntityForName:@"Enclosure" inManagedObjectContext:context];
            enclosure.url = enclosureURL;
            enclosure.size = [NSNumber numberWithInteger:fileSize.integerValue];
            enclosure.type = fileType; // @"webpage/youtube" @"webpage/hulu"
            enclosure.episode = episode;
            [episode addEnclosuresObject:enclosure];
            
            episode.show = self;
            [self addEpisodesObject:episode];
        }
        
        //NSLog(@"%@", self);
    }];
}

@end
