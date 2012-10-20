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
@dynamic desc;
@dynamic genre;
@dynamic image;
@dynamic hasNew;
@dynamic schedule;
@dynamic unwatchedCount;
@dynamic website;
@dynamic channel;
@dynamic episodes;
@dynamic feeds;

#pragma mark - Faux Entities

- (NSArray*)unwatchedEpisodes
{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"published" ascending:YES];
    NSArray *sortedEpisodes = [self.episodes sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unwatched == %@", [NSNumber numberWithBool:YES]];
    return [sortedEpisodes filteredArrayUsingPredicate:predicate];
}

- (NSString*)subtitle
{
    if(self.unwatchedCount.intValue > 0)
        return [NSString stringWithFormat:@"%d", self.unwatchedCount.intValue];
    else
        return @"";
}

- (NSString*)allEpisodesString
{
    if(self.episodes.count > 0)
        if(self.unwatchedCount.intValue == 0)
            return [NSString stringWithFormat:@"No Unwatched Episodes • %ld Total", self.episodes.count];
        else
            return [NSString stringWithFormat:@"%d Unwatched • %ld Total", self.unwatchedCount.intValue, self.episodes.count];
    else
        return @"No Episodes";
}

- (NSImage*)imageValue
{
    return [[NSImage alloc] initWithData:self.image];
    //else
    //return default image
}

#pragma mark - Setters

- (void)setUnwatchedCount:(NSNumber*)_unwatchedCount
{
    [self willChangeValueForKey:@"unwatchedEpisodes"];
    [self willChangeValueForKey:@"allEpisodesString"];
    [self willChangeValueForKey:@"subtitle"];
    [self willChangeValueForKey:@"unwatchedCount"];
    
    [self setPrimitiveValue:_unwatchedCount forKey:@"unwatchedCount"];
    
    [self didChangeValueForKey:@"unwatchedCount"];
    [self didChangeValueForKey:@"subtitle"];
    [self didChangeValueForKey:@"allEpisodesString"];
    [self didChangeValueForKey:@"unwatchedEpisodes"];
}

#pragma mark - Actions

- (void)markAllWatched
{
    for(Episode *episode in self.episodes)
        episode.unwatched = NO;
    
    self.unwatchedCount = [NSNumber numberWithInt:0];
}

#pragma mark - Network

- (void)reload
{
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
            {
                if(feed.type.intValue == FeedTypeHulu)
                    [self updateHuluFeed:feed];
                else
                    [self updatePodcastFeed:feed];
            }
        }
    }];
}

- (void)updatePodcastFeed:(Feed*)feed
{
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
            if(!title) title = feed.url;
            
            NSString *desc = [XMLReader stringFromDictionary:showDic withKeys:@"description", @"text", nil];
            if(!desc) desc = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:subtitle", @"text", nil];
            if(!desc) desc = @"";
            
            NSString *image = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:image", @"href", nil];
            if(!image) image = [XMLReader stringFromDictionary:showDic withKeys:@"image", @"url", @"text", nil];
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
                 [self willChangeValueForKey:@"imageValue"];
                 self.image = data;
                 [self didChangeValueForKey:@"imageValue"];
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
            if(!pubDate)
            {
                [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
                pubDate = [dateFormat dateFromString:pubDateString];
            }
            if(!pubDate) pubDate = [NSDate dateWithTimeIntervalSince1970:0];
            
            NSString *duration = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"duration", nil];
            if(!duration) duration = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:duration", @"text", nil];
            int i = 0, seconds = 0;
            for(NSString *element in [[duration componentsSeparatedByString:@":"] reverseObjectEnumerator])
            {
                seconds += element.intValue*pow(60,i);
                i++;
            }
            duration = [NSString stringWithFormat:@"%d", seconds];
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
                    continue;
                }
                else
                {
                    [self removeEpisodesObject:oldestEpisode];
                }
            }
            
            self.hasNew = [NSNumber numberWithBool:YES];
            
            Episode *episode = [NSEntityDescription insertNewObjectForEntityForName:@"Episode"
                                                             inManagedObjectContext:context];
            episode.title = title;
            episode.desc = desc;
            episode.descShort = descShort;
            episode.duration = [NSNumber numberWithInt:duration.intValue];
            episode.website = link;
            episode.published = pubDate;
            
            if(firstLoad)
            {
                if([episodes indexOfObject:epiDic] == 0)
                {
                    episode.unwatched = [NSNumber numberWithBool:YES];
                    self.unwatchedCount = [NSNumber numberWithInt:1];
                }
                else
                {
                    episode.unwatched = [NSNumber numberWithBool:NO];
                }
            }
            else
            {
                episode.unwatched = [NSNumber numberWithBool:YES];
                self.unwatchedCount = [NSNumber numberWithInt:(self.unwatchedCount.intValue+1)];
            }
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:image]];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
            {
                [episode willChangeValueForKey:@"imageValue"];
                episode.image = data;
                [episode didChangeValueForKey:@"imageValue"];
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
    }];
}

/*
http://www.hulu.com/api/2.0/videos.json?video_type[]=episode&sort=released_at&order=desc&items_per_page=50&show_id=70, 44, 1968, 2505, 7529, 2553, 6345
 */
- (void)updateHuluFeed:(Feed*)feed
{
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
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        BOOL firstLoad = NO;
        
        if(self.episodes.count == 0)
            firstLoad = YES;
        
        if(!self.desc)
        {
            firstLoad = YES;
            
            NSDictionary *show = [[[[json objectForKey:@"data"] lastObject] objectForKey:@"video"] objectForKey:@"show"];
            
            NSString *title = [show objectForKey:@"name"];
            NSString *desc = [show objectForKey:@"description"];
            NSString *genre = [show objectForKey:@"genre"];
            NSString *image = [NSString stringWithFormat:@"http://ib2.huluim.com/show/%@?size=220x124", [show objectForKey:@"id"]];
            
            self.title = title;
            self.desc = desc;
            self.website = [NSString stringWithFormat:@"http://www.hulu.com/%@", [show objectForKey:@"canonical_name"]];
            self.genre = genre;
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:image]];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 [self willChangeValueForKey:@"imageValue"];
                 self.image = data;
                 [self didChangeValueForKey:@"imageValue"];
             }];
        }
        
        NSArray *episodes = [json objectForKey:@"data"];
        for(NSDictionary *dict in episodes)
        {
            NSDictionary *epiDic = [dict objectForKey:@"video"];
            
            NSString *title = [epiDic objectForKey:@"title"];
            NSString *desc = [epiDic objectForKey:@"description"];
            NSString *descShort = [epiDic objectForKey:@"description"];
            
            NSString *image =  [NSString stringWithFormat:@"http://ib1.huluim.com/video/%@?size=220x124",
                                [epiDic objectForKey:@"content_id"]];
            
            NSString *pubDateString = [epiDic objectForKey:@"available_at"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            NSDate *pubDate = [dateFormat dateFromString:pubDateString];
            
            NSString *expireDateString = [epiDic objectForKey:@"expires_at"];
            NSDate *expireDate = [dateFormat dateFromString:expireDateString];
            
            NSString *duration  = [epiDic objectForKey:@"duration"];
            
            NSString *link = [NSString stringWithFormat:@"http://www.hulu.com/watch/%@", [epiDic objectForKey:@"id"]];
            NSString *enclosureURL = link;
            NSString *fileSize =  @"0";
            NSString *fileType = @"webpage/hulu";
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@ && published == %@", title, pubDate];
            if([[self.episodes filteredSetUsingPredicate:predicate] count] > 0)
            {
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
                    continue;
                }
                else
                {
                    [self removeEpisodesObject:oldestEpisode];
                }
            }
            
            
            self.hasNew = [NSNumber numberWithBool:YES];
            
            Episode *episode = [NSEntityDescription insertNewObjectForEntityForName:@"Episode"
                                                             inManagedObjectContext:context];
            episode.title = title;
            episode.desc = desc;
            episode.descShort = descShort;
            episode.duration = [NSNumber numberWithInt:duration.intValue];
            episode.website = link;
            episode.published = pubDate;
            episode.expires = expireDate;
            
            if(firstLoad)
            {
                if([episodes indexOfObject:dict] == 0)
                {
                    episode.unwatched = [NSNumber numberWithBool:YES];
                    self.unwatchedCount = [NSNumber numberWithInt:1];
                }
                else
                {
                    episode.unwatched = [NSNumber numberWithBool:NO];
                }
            }
            else
            {
                episode.unwatched = [NSNumber numberWithBool:YES];
                self.unwatchedCount = [NSNumber numberWithInt:(self.unwatchedCount.intValue+1)];
            }
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:image]];
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 [episode willChangeValueForKey:@"imageValue"];
                 episode.image = data;
                 [episode didChangeValueForKey:@"imageValue"];
             }];
            
            
            Enclosure *enclosure = [NSEntityDescription insertNewObjectForEntityForName:@"Enclosure" inManagedObjectContext:context];
            enclosure.url = enclosureURL;
            enclosure.size = [NSNumber numberWithInteger:fileSize.integerValue];
            enclosure.type = fileType;
            enclosure.episode = episode;
            [episode addEnclosuresObject:enclosure];
            
            episode.show = self;
            [self addEpisodesObject:episode];
        }
    }];
}

@end
