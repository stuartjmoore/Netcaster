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

- (void)reload
{
    // Only one feed is supported right now
    Feed *feed = self.feeds.anyObject;
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feed.url]];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
    completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        NCAppDelegate *delegate = [NSApp delegate];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        NSDictionary *RSS = [XMLReader dictionaryForXMLData:data error:nil];
        
        if(!self.desc) //self.episodes.count == 0?
        {
            NSDictionary *showDic = [[RSS objectForKey:@"rss"] objectForKey:@"channel"];
            
            NSString *title = [[showDic objectForKey:@"title"] objectForKey:@"text"];
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *desc = [[showDic objectForKey:@"description"] objectForKey:@"text"];
            if(!desc)
                desc = [[showDic objectForKey:@"itunes:subtitle"] objectForKey:@"text"];
            desc = [desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *image = [[showDic objectForKey:@"itunes:image"] objectForKey:@"href"];
            image = [image stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *link = [[showDic objectForKey:@"link"] objectForKey:@"text"];
            link = [link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *author = [[showDic objectForKey:@"itunes:author"] objectForKey:@"text"];
            author = [author stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *genre = [[showDic objectForKey:@"itunes:category"] objectForKey:@"text"];
            genre = [genre stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            
            self.title = title;
            self.desc = desc;
            self.website = link;
            self.genre = genre;
            
            Channel *channel = [NSEntityDescription insertNewObjectForEntityForName:@"Channel" inManagedObjectContext:context];
            channel.title = author;
            self.channel = channel;
        }
        
        NSArray *episodes = [[[RSS objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];
        NSLog(@"episodes.count %ld", episodes.count);
        for(NSDictionary *epiDic in episodes)
        {
            NSString *title = [XMLReader stringFromDictionary:epiDic withKeys:@"title", @"text", nil];
            if(!title)
                title = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"media:title", @"text", nil];
            
            NSString *desc = [XMLReader stringFromDictionary:epiDic withKeys:@"description", @"text", nil];
            if(!desc)
                desc = [XMLReader stringFromDictionary:epiDic withKeys:@"content:encoded", @"text", nil];
            if(!desc)
                desc = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:subtitle", @"text", nil];
            
            NSString *image = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"media:thumbnail", @"url", nil];
            if(!image)
                image = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:image", @"href", nil];
            
            NSString *pubDateString = [XMLReader stringFromDictionary:epiDic withKeys:@"pubDate", @"text", nil];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
            NSDate *pubDate = [dateFormat dateFromString:pubDateString];
            
            NSString *duration = [XMLReader stringFromDictionary:epiDic withKeys:@"itunes:duration", @"text", nil];
            if(!duration)
                duration = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"duration", nil];
            
            NSString *link = [XMLReader stringFromDictionary:epiDic withKeys:@"link", @"text", nil];
            
            NSString *enclosureURL = [XMLReader stringFromDictionary:epiDic withKeys:@"enclosure", @"url", nil];
            if(!enclosureURL)
                enclosureURL = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"url", nil];
            
            NSString *fileSize = [XMLReader stringFromDictionary:epiDic withKeys:@"enclosure", @"length", nil];
            if(!fileSize)
                fileSize = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"fileSize", nil];
            
            NSString *fileType = [XMLReader stringFromDictionary:epiDic withKeys:@"enclosure", @"type", nil];
            if(!fileType)
                fileType = [XMLReader stringFromDictionary:epiDic withKeys:@"media:content", @"type", nil];
            

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@ && published == %@", title, pubDate];
            if([[self.episodes filteredSetUsingPredicate:predicate] count] > 0)
            {
                NSLog(@"%@ exists", title);
                continue;
            }
            
            
            if(self.episodes.count >= MAX_EPISODES)
            {
                // if younger than oldest
                //  delete oldest
                // else
                //  continue;
            }
            
                
            Episode *episode = [NSEntityDescription insertNewObjectForEntityForName:@"Episode" inManagedObjectContext:context];
            episode.title = title;
            episode.desc = desc;
            episode.duration = [NSNumber numberWithInteger:duration.integerValue];
            episode.website = link;
            episode.published = pubDate;
            
            Enclosure *enclosure = [NSEntityDescription insertNewObjectForEntityForName:@"Enclosure" inManagedObjectContext:context];
            enclosure.url = enclosureURL;
            enclosure.size = [NSNumber numberWithInteger:fileSize.integerValue];
            enclosure.type = fileType;
            enclosure.episode = episode;
            [episode addEnclosuresObject:enclosure];
            
            episode.show = self;
            [self addEpisodesObject:episode];
            
            //NSLog(@"%@", episode);
        }
        
        NSLog(@"%@", self);
        
        /*
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if ([response respondsToSelector:@selector(allHeaderFields)])
        {
            NSDictionary *dictionary = [httpResponse allHeaderFields];
            NSString *lastModified = [dictionary objectForKey:@"Last-Modified"]);
        }*/
    }];
}

@end
