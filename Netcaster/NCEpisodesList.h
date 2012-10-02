//
//  NCEpisodesList.h
//  Netcaster
//
//  Created by Stuart Moore on 10/2/12.
//  Copyright (c) 2012 Stuart Moore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCEpisodesList : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) NSArray *episodes;

@end
