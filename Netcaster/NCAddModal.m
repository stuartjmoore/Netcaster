//
//  NCAddModal.m
//  Netcaster
//
//  Created by Stuart Moore on 9/30/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import "NCAddModal.h"
#import "XMLReader.h"

@implementation NCAddModal

#pragma mark - Actions

- (void)controlTextDidChange:(NSNotification*)notification
{
    NSURL *url = [NSURL URLWithString:self.urlField.stringValue];
    
    self.showDetailTitle.stringValue = @"";
    self.showDetailDesc.stringValue = @"";
    self.showDetailImage.image = nil;
    [self.addButton setEnabled:NO];
    
    [self.showDetailView removeFromSuperview];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
                              self.frame.size.width, 116+20) display:NO animate:YES];
    
    if(url && url.scheme && url.host)
    {
        [self.detailLoadingIndicator startAnimation:nil];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            [self.detailLoadingIndicator stopAnimation:nil];
         
            if(error)
                return;
            
            if([url.host hasSuffix:@"hulu.com"])
            {
                //http://www.hulu.com/api/2.0/videos.json?video_type[]=episode&sort=released_at&order=asc&items_per_page=50&show_id=6345
             
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSDictionary *show = [[[[json objectForKey:@"data"] lastObject] objectForKey:@"video"] objectForKey:@"show"];
                
                NSString *title = [show objectForKey:@"name"];
                NSString *desc = [show objectForKey:@"description"];
                NSString *image = [NSString stringWithFormat:@"http://ib2.huluim.com/show/%@?size=220x124", [show objectForKey:@"id"]];
                
                if(title && desc && ![title isEqualToString:@""] && ![desc isEqualToString:@""])
                {
                    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                              self.frame.size.width, 290) display:NO animate:YES];
                    
                    self.showDetailView.frame = self.detailField.bounds;
                    self.showDetailView.autoresizingMask = 63;
                    [self.detailField addSubview:self.showDetailView];
                    
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:image]];
                    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                     {
                         NSImage *image = [[NSImage alloc] initWithData:data];
                         self.showDetailImage.image = image;
                     }];
                    
                    self.showDetailTitle.stringValue = title;
                    self.showDetailDesc.stringValue = desc;
                    [self.addButton setEnabled:YES];
                }
            }
            else if([url.absoluteString hasPrefix:@"http://gdata.youtube.com/feeds/api/playlists/"])
            {
                // http://gdata.youtube.com/feeds/api/playlists/4F80C7D2DC8D9B6C
                
                NSDictionary *RSS = [XMLReader dictionaryForXMLData:data error:&error];
                
                if(error)
                    return;
                
                NSDictionary *showDic = [RSS objectForKey:@"feed"];
                
                NSString *title = [XMLReader stringFromDictionary:showDic withKeys:@"title", @"text", nil];
                if(!title) title = @"";
                
                NSString *desc = [XMLReader stringFromDictionary:showDic withKeys:@"subtitle", @"text", nil];
                if(!desc) desc = @"";
                
                NSString *image = [[[[showDic objectForKey:@"media:group"] objectForKey:@"media:thumbnail"] lastObject] objectForKey:@"url"];
                if(!image) image = @"";
                
                if(title && desc && ![title isEqualToString:@""] && ![desc isEqualToString:@""])
                {
                    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                              self.frame.size.width, 290) display:NO animate:YES];
                    
                    self.showDetailView.frame = self.detailField.bounds;
                    self.showDetailView.autoresizingMask = 63;
                    [self.detailField addSubview:self.showDetailView];
                    
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:image]];
                    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                     {
                         NSImage *image = [[NSImage alloc] initWithData:data];
                         self.showDetailImage.image = image;
                     }];
                    
                    self.showDetailTitle.stringValue = title;
                    self.showDetailDesc.stringValue = desc;
                    [self.addButton setEnabled:YES];
                }
            }
            else
            {
                NSDictionary *RSS = [XMLReader dictionaryForXMLData:data error:&error];
                
                if(error)
                    return;
                
                NSDictionary *showDic = [[RSS objectForKey:@"rss"] objectForKey:@"channel"];
                
                NSString *title = [XMLReader stringFromDictionary:showDic withKeys:@"title", @"text", nil];
                if(!title) title = @"";
                
                NSString *desc = [XMLReader stringFromDictionary:showDic withKeys:@"description", @"text", nil];
                if(!desc) desc = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:subtitle", @"text", nil];
                if(!desc) desc = @"";
                
                NSString *image = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:image", @"href", nil];
                if(!image) image = [XMLReader stringFromDictionary:showDic withKeys:@"image", @"url", @"text", nil];
                if(!image) image = @"";
                
                if(title && desc && ![title isEqualToString:@""] && ![desc isEqualToString:@""])
                {
                    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                              self.frame.size.width, 290) display:NO animate:YES];
                    
                    self.showDetailView.frame = self.detailField.bounds;
                    self.showDetailView.autoresizingMask = 63;
                    [self.detailField addSubview:self.showDetailView];
                    
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:image]];
                    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                    {
                         NSImage *image = [[NSImage alloc] initWithData:data];
                         self.showDetailImage.image = image;
                    }];
                    
                    self.showDetailTitle.stringValue = title;
                    self.showDetailDesc.stringValue = desc;
                    [self.addButton setEnabled:YES];
                }
            }
        }];
    }
}

#pragma mark - Finish

- (IBAction)addURL:(id)sender
{
    [NSApp endSheet:self returnCode:NSOKButton];
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:self returnCode:NSCancelButton];
}

@end
