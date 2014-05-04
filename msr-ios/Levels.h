//
//  Levels.h
//  msr-ios
//
//  Created by barari on 5/3/14.
//  Copyright (c) 2014 o2bt. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import <Foundation/Foundation.h>

@interface Levels : NSObject
/*
 cur_background 1
 cur_background 2
 cur_background 3
 asset_dict: backgrounds, clouds, missiles
 level_length array
 loop_counter
 constants
 
 */

-(id)init:(CCScene*)game;
-(void)addCloud:(CCTime)dt;
-(void)moveBackground:(CCTime)delta;




@end
