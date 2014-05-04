//
//  Levels.m
//  msr-ios
//
//  Created by barari on 5/3/14.
//  Copyright (c) 2014 o2bt. All rights reserved.
//

#import "Levels.h"

@implementation Levels
{
    CCScene *game_scene;
    CCSprite *curr_transition_img;
    CCSprite *curr_loop_img_1;
    CCSprite *curr_loop_img_2;
    NSDictionary *assets;
    NSArray *level_lengths;
    NSInteger *loop_counter;
    BOOL inLoop;
}


-(id)init:(CCScene*)game {
    self = [super init];
    if (!self) return(nil);
    
    game_scene = game;
    assets = [[NSDictionary alloc] initWithObjectsAndKeys:
              [NSArray arrayWithObjects:@"3transition1.png", nil], @"transitions",
              [NSArray arrayWithObjects:@"3backgroundloop1.png", nil], @"backgrounds",
              [NSArray arrayWithObjects:@"rocket.png", nil], @"missiles",
              [NSArray arrayWithObjects:@"cloud_1.png", nil], @"clouds",
              nil];
    curr_loop_img_1 = curr_loop_img_2 = assets[@"backgrounds"][0];
    curr_transition_img = assets[@"transitions"][0];
    inLoop = NO;
}

-(void)addCloud:(CCTime)dt{
    
}

-(void)moveBackground:(CCTime)delta{
    
}


@end
