//
//  Player.m
//  msr-ios
//
//  Created by Macgill on 4/22/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import "Player.h"


@implementation Player

@synthesize _sprite;

/* Delete this comment */

-(id)initWorld: (CCPhysicsNode *)_physicsWorld withPosition:(CGPoint)_positionPlayer andScene:(GameScene *)_scene{
    self = [super init];
    
    _sprite = [CCSprite spriteWithImageNamed:@"martianSmall.png"];
    _sprite.position  = _positionPlayer;
    _sprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _sprite.contentSize} cornerRadius:0]; // 1
    _sprite.physicsBody.collisionGroup = @"playerGroup"; // 2
    _sprite.physicsBody.collisionType  = @"playerCollision";
    [_physicsWorld addChild:_sprite];
    
    // Animate sprite with action
    CCActionRotateBy* actionSpin = [CCActionRotateBy actionWithDuration:2.5f angle:360];
    [_sprite runAction:[CCActionRepeatForever actionWithAction:actionSpin]];    
    
    return self;
}

@end


