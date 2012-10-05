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

- (void)awakeFromNib
{
    self.showDetailView.frame = self.detailField.bounds;
    self.showDetailView.autoresizingMask = 63;
    [self.detailField addSubview:self.showDetailView];
}

#pragma mark - Actions

- (void)controlTextDidChange:(NSNotification*)notification
{
    NSURL *url = [NSURL URLWithString:self.urlField.stringValue];
    
    if(url && url.scheme && url.host)
    {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            if(error)
                return;
            
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
            if(!image) image = @"";
            
            NSString *link = [XMLReader stringFromDictionary:showDic withKeys:@"link", @"text", nil];
            if(!link) link = @"";
            
            NSString *author = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:author", @"text", nil];
            if(!author) author = @"";
            
            NSString *genre = [XMLReader stringFromDictionary:showDic withKeys:@"itunes:category", @"text", nil];
            if(!genre) genre = @"";
            
            NSLog(@"%@ %@ %@ %@ %@ %@", title, desc, link, image, author, genre);
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
