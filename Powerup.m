//
//  Powerup.m
//  msr-ios
//
//  Created by Macgill on 4/25/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import "Powerup.h"


@implementation Powerup

@synthesize _sprite;

-(id)initWithPhysicsWorld:(CCPhysicsNode *)_physicsWorld andGameScene:(GameScene *)_scene {
    self = [super init];
    _sprite = [CCSprite spriteWithImageNamed:@"parachute.png"];
    
    // Make appear at a random X coordinate
    int minX = _sprite .contentSize.width / 2;
    int maxX = _scene.contentSize.width - _sprite.contentSize.width / 2;
    int rangeX = maxX - minX;
    int randomX = (arc4random() % rangeX) + minX;
    
    int minDuration = 8.0;
    int maxDuration = 10.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    _sprite.position = CGPointMake(randomX, 0);//-(self.contentSize.height + missile.contentSize.height));
    _sprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _sprite.contentSize} cornerRadius:0];
    _sprite.physicsBody.collisionGroup = @"powerupGroup";
    _sprite.physicsBody.collisionType  = @"powerupCollision";
    [_physicsWorld addChild:_sprite z:-2];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(randomX, _scene.contentSize.height + _sprite.contentSize.height)];
    CCAction *actionRemove = [CCActionRemove action];
    [_sprite runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];

    
    return self;
}


@end
