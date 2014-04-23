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


-(id)initWorld: (CCPhysicsNode *)_physicsWorld andScene:(GameScene *)_scene{
    self = [super init];
    
    _sprite = [CCSprite spriteWithImageNamed:@"martian.png"];
    _sprite.position  = ccp(_scene.contentSize.width/2,4*_scene.contentSize.height/5);
    _sprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _sprite.contentSize} cornerRadius:0]; // 1
    _sprite.physicsBody.collisionGroup = @"playerGroup"; // 2
    [_physicsWorld addChild:_sprite];
    
    return self;
}

@end


