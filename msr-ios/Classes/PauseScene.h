//  PauseScene.h
//  msr-ios
//
//  Created by barari on 5/2/14.
//  Copyright o2bt 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"
//#import "Levels.h"
#import <CoreMotion/CoreMotion.h>
#import <Social/Social.h>

// -----------------------------------------------------------------------

@interface PauseScene : CCScene

// -----------------------------------------------------------------------

+ (PauseScene *)scene;
- (id)init;
- (void)transition;
// -----------------------------------------------------------------------
@end