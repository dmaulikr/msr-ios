//
//  Missile.m
//  msr-ios
//
//  Created by Macgill on 4/22/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import "Missile.h"


@implementation Missile

@synthesize missile;
@synthesize player;

-(id)initPlayer:(Player *)_martian andWorld:(CCPhysicsNode *)_physicsWorld andScene:(GameScene *)_scene {
    
    self = [super init];
    //missile = [CCSprite spriteWithImageNamed:@"rocket.png"];
    //missile = [CCSprite spriteWithImageNamed:@"plane_2.png"];
    missile = [CCSprite spriteWithImageNamed:@"comet3.png"];
    
    //keep track of player
    player = _martian;
        
    // Make appear at a random X coordinate
    int minX = missile.contentSize.width / 2;
    int maxX = _scene.contentSize.width - missile.contentSize.width / 2;
    int rangeX = maxX - minX;
    int randomX = (arc4random() % rangeX) + minX;
    
    int minDuration = 2.0;
    int maxDuration = 7.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    missile.position = CGPointMake(randomX, 0);//-(self.contentSize.height + missile.contentSize.height));
    missile.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, missile.contentSize} cornerRadius:0];
    missile.physicsBody.collisionGroup = @"aerialGroup";
    missile.physicsBody.collisionType  = @"missileCollision";
    [_physicsWorld addChild:missile z:-1];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(randomX, _scene.contentSize.height + missile.contentSize.height)];
    CCAction *actionRemove = [CCActionRemove action];
    [missile runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
    
    return self;
}



@end
