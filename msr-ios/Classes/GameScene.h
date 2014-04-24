//
//  HelloWorldScene.h
//  msr-ios
//
//  Created by barari on 4/19/14.
//  Copyright o2bt 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import <CoreMotion/CoreMotion.h>

// -----------------------------------------------------------------------

/**
 *  The main scene
 */
@interface GameScene : CCScene <CCPhysicsCollisionDelegate, UIAccelerometerDelegate>

@property (strong,nonatomic) CMMotionManager *manager;

// -----------------------------------------------------------------------

+ (GameScene *)scene;
- (id)init;
- (void) getValues:(NSTimer *) timer;
// -----------------------------------------------------------------------
@end