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

@implementation Show

@dynamic cast;
@dynamic channelName;
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
        NSArray *episodes = [[[RSS objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];
        
        for(NSDictionary *epiDic in episodes)
        {
            NSString *title = [[epiDic objectForKey:@"title"] objectForKey:@"text"];
            if(!title)
                title = [[[epiDic objectForKey:@"media:content"] objectForKey:@"media:title"] objectForKey:@"text"];
            [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *desc = [[epiDic objectForKey:@"description"] objectForKey:@"text"];
            if(!desc)
                desc = [[epiDic objectForKey:@"content:encoded"] objectForKey:@"text"];
            if(!desc)
                desc = [[epiDic objectForKey:@"itunes:subtitle"] objectForKey:@"text"];
            [desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *image = [[[epiDic objectForKey:@"media:content"] objectForKey:@"media:thumbnail"] objectForKey:@"url"];
            if(!image)
                image = [[epiDic objectForKey:@"itunes:image"] objectForKey:@"href"];
            [image stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *pubDate = [[epiDic objectForKey:@"pubDate"] objectForKey:@"text"];
            [pubDate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *duration = [[epiDic objectForKey:@"itunes:duration"] objectForKey:@"text"];
            if(!duration)
                duration = [[epiDic objectForKey:@"media:content"] objectForKey:@"duration"];
            [duration stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *link = [[epiDic objectForKey:@"link"] objectForKey:@"text"];
            [link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *enclosureURL = [[epiDic objectForKey:@"enclosure"] objectForKey:@"url"];
            if(!enclosureURL)
                enclosureURL = [[epiDic objectForKey:@"media:content"] objectForKey:@"url"];
            [enclosureURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *fileSize = [[epiDic objectForKey:@"enclosure"] objectForKey:@"length"];
            if(!fileSize)
                fileSize = [[epiDic objectForKey:@"media:content"] objectForKey:@"fileSize"];
            [fileSize stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *fileType = [[epiDic objectForKey:@"enclosure"] objectForKey:@"type"];
            if(!fileType)
                fileType = [[epiDic objectForKey:@"media:content"] objectForKey:@"type"];
            [fileType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            
            Episode *episode = [NSEntityDescription insertNewObjectForEntityForName:@"Episode" inManagedObjectContext:context];
            episode.title = title;
            episode.desc = desc;
            episode.duration = [NSNumber numberWithInteger:duration.integerValue];
            episode.website = link;
            
            Enclosure *enclosure = [NSEntityDescription insertNewObjectForEntityForName:@"Enclosure" inManagedObjectContext:context];
            enclosure.url = enclosureURL;
            enclosure.size = [NSNumber numberWithInteger:fileSize.integerValue];
            enclosure.type = fileType;
            enclosure.episode = episode;
            [episode addEnclosuresObject:enclosure];
            
            episode.show = self;
            [self addEpisodesObject:episode];
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
