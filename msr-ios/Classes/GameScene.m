//
//  GameScene.m
//  msr-ios
//
//  Created by barari on 4/19/14.
//  Copyright o2bt 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "GameScene.h"
#import "IntroScene.h"
#import "Player.h"
#import "Missile.h"

// -----------------------------------------------------------------------
#pragma mark - GameScene
// -----------------------------------------------------------------------
const int MAX_MISSILES = 4;
bool DEBUGbool = false;
const int BACKGROUND_SCROLL_SPEED = 4;


@implementation GameScene
{
    CCSprite *_background1;
    CCSprite *_background2;
    CCPhysicsNode *_physicsWorld;
    CCLabelTTF *_scoreLabel;
    Player *_martian;
    Missile *_missile;
    NSUserDefaults *_defaults;
    int _score;
    NSMutableArray * _missilesArray; //create an array of missiles,
}

@synthesize manager;

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (GameScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node + set up motion manager
    self.userInteractionEnabled = YES;
    self.manager = [[CMMotionManager alloc] init];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getValues:) userInfo:nil repeats:YES];
    self.manager.accelerometerUpdateInterval = 0.05;
    [self.manager startAccelerometerUpdates];
    
    //add images as backgrounds
    _background1 = [CCSprite spriteWithImageNamed:@"skybackground.png"];
    _background1.position = CGPointMake(10,0);
    [self addChild:_background1 z:-3];
    
    
    _background2 = [CCSprite spriteWithImageNamed:@"skybackground2.png"];
    _background2.position = CGPointMake(10,0);
    [self addChild:_background2 z:-3];
    
    //set up the physics world
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    _physicsWorld.debugDraw = NO; //for debug put yes
    _physicsWorld.collisionDelegate = self;
    [self addChild:_physicsWorld z:-1];
    
    _martian = [[Player alloc] initWorld:_physicsWorld andScene:self];
    
    //init and alloc mutable missile array
    _missilesArray = [[NSMutableArray alloc] init];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
    
    // Initialize the score & its label
    _score = 0;
    _scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",_score] fontName:@"Chalkduster" fontSize:14.0f];
    _scoreLabel.positionType = CCPositionTypeNormalized;
    _scoreLabel.color = [CCColor blackColor];
    _scoreLabel.position = ccp(0.15f, 0.95f); // Top right corner
    [self addChild:_scoreLabel];
    

    // Initialize the highscore table
    _defaults = [NSUserDefaults standardUserDefaults];

    
	return self;
}


// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    [self schedule:@selector(moveBackground:) interval:0.03];
    [self schedule:@selector(addCloud:) interval:1.5];
    [self schedule:@selector(addMissile:) interval:2];
    [self schedule:@selector(incrementScore) interval:0.1];
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

- (void)addCloud:(CCTime)dt {
    CCSprite *cloud = [CCSprite spriteWithImageNamed:@"cloud.png"];
    
    // Set time and space bounds for cloud generation
    int maxX = self.contentSize.width;
    int randomX = (arc4random() % maxX);
    int minDuration = 1.0;
    int maxDuration = 3.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    cloud.position = CGPointMake(randomX, 0);
    [self addChild:cloud z:-2];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(randomX, self.contentSize.height + cloud.contentSize.height)];
    CCAction *actionRemove = [CCActionRemove action];
    [cloud runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
}
// -----------------------------------------------------------------------
#pragma mark - Scoring
// -----------------------------------------------------------------------

- (void)incrementScore
{
    _score++;
    [_scoreLabel setString:[NSString stringWithFormat:@"Score: %03d", _score]];
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    
    // Move our sprite to touch location
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.4f position:touchLoc];
    [_martian._sprite runAction:actionMove];
}


-(void) getValues:(NSTimer *) timer {
    NSLog([NSString stringWithFormat:@"%.2f", fmod((self.manager.accelerometerData.acceleration.y * 20), 20)]);
    CGPoint touchLoc = _martian._sprite.position;
    touchLoc.x += self.manager.accelerometerData.acceleration.x * 80.0;
    touchLoc.y += self.manager.accelerometerData.acceleration.y * 30 + 20.0;
    
    // Move our sprite to touch location
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.4f position:touchLoc];
    [_martian._sprite runAction:actionMove];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------
#pragma mark - Move Scrolling Background
// -----------------------------------------------------------------------

-(void)moveBackground:(CCTime)delta
{
    CGPoint bgPos1 = _background1.position;
    CGPoint bgPos2 = _background2.position;
    bgPos1.y = bgPos1.y + BACKGROUND_SCROLL_SPEED;
    bgPos2.y = bgPos2.y + BACKGROUND_SCROLL_SPEED;
    
    /*int backgroundH = _background1.contentSize.height - (2 * self.contentSize.width);
    CCLOG(@"background1 height - contentsize height is %d", backgroundH);
    int otherbackground = bgPos1.y;
    CCLOG(@"bspos1.y is %d", otherbackground);
    int other = bgPos1.y  - _background1.contentSize.height/2;
    CCLOG(@"bgPos2.y is %d", other);*/

    
    if (bgPos1.y > (_background1.contentSize.height - (2 * self.contentSize.width))) {
        bgPos1.y = 0;
    }
    bgPos2.y = bgPos1.y - _background1.contentSize.height/2;
    

    bgPos1.y = (int)bgPos1.y;
    bgPos2.y = (int)bgPos2.y;
    _background1.position = bgPos1;
    _background2.position = bgPos2;
}
// -----------------------------------------------------------------------
#pragma mark - Add Missile
// -----------------------------------------------------------------------
-(void)addMissile:(CCTime)delta
{
    _missile = [[Missile alloc] initPlayer:_martian andWorld:_physicsWorld andScene:self];
    //add missile to array
    [_missilesArray addObject: _missile];
    [self schedule:(@selector(trackPlayerwithMissile)) interval:0.07];
}

// -----------------------------------------------------------------------
#pragma mark - For missiles to track players
// -----------------------------------------------------------------------

-(void)trackPlayerwithMissile{

    //remove all missiles that have passed end of screen
    [self cleanUpArray];
    
    int num_missiles = (int)[_missilesArray count];
    CGPoint playerPos = _martian._sprite.position;
    
    if(DEBUGbool == true) {
        CCLOG(@"number of missiles in num_missiles %d", num_missiles);
    }
    
    for (int i= 0; i < num_missiles; i++) {
        Missile *cur_miss = [_missilesArray objectAtIndex:(i)];
        CGPoint missilePos = cur_miss.missile.position;
        
        if ((playerPos.x >= missilePos.x) && (playerPos.y > missilePos.y)) {
            missilePos.x = missilePos.x + 1;
            cur_miss.missile.position = missilePos;
        } else if ((playerPos.x <= missilePos.x) && (playerPos.y > missilePos.y)) {
            missilePos.x = missilePos.x - 1;
            cur_miss.missile.position = missilePos;
        }


    }
    
    /*
    CGPoint playerPos = _martian._sprite.position;
    CGPoint missilePos = _missile.missile.position;
    
    //ONLY WORKS ON ONE MISSILE AT A TIME
    
    //CCLOG(@"Players position is @ %@", NSStringFromCGPoint(playerPos));
    //CCLOG(@"Missile position is @ %@", NSStringFromCGPoint(missilePos));
    
    //move the missile towards the player
    if ((playerPos.x >= missilePos.x) && (playerPos.y > missilePos.y)) {
        missilePos.x = missilePos.x + .75;
        _missile.missile.position = missilePos;
    } else if ((playerPos.x <= missilePos.x) && (playerPos.y > missilePos.y)) {
        missilePos.x = missilePos.x - .75;
        _missile.missile.position = missilePos;
    }
    //CCLOG(@"Trackplayer called");*/
    
}

// -----------------------------------------------------------------------
#pragma mark - Remove missiles that have passed off the screen
// -----------------------------------------------------------------------

-(void)cleanUpArray {
    for (int i= 0; i < (int)[_missilesArray count]; i++) {
        Missile *cur_miss = [_missilesArray objectAtIndex:(i)];
        if (cur_miss.missile.position.y > (self.contentSize.height + cur_miss.missile.contentSize.height)) {
            [_missilesArray removeObjectAtIndex:(i)];
            i--; //decrement i becuase we just removed one index
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Collision Detection
// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair missileCollision:(CCNode *)missile playerCollision:(CCNode *)player {
        
    CCSprite *boomer = [CCSprite spriteWithImageNamed:(@"boomer.png")];
    CGPoint new_pos = missile.position;
    new_pos.y = new_pos.y + 10;
    boomer.position  = new_pos;
    [self addChild:boomer z:-1];

    [missile removeFromParent];
    [player removeFromParent];
    
    //[[CCDirector sharedDirector] pause];
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]
                               withTransition:[CCTransition transitionCrossFadeWithDuration:0.8f]];
    
    /* HIGHSCORE MANAGEMENT */
    int highScore;
    
    // If the app is running for the first time, set the high score
    if (![_defaults objectForKey:@"firstRun"]) {
        [_defaults setObject:[NSDate date] forKey:@"firstRun"];
        [_defaults setFloat:_score forKey:@"SavedHighScore"];
        NSLog(@"Highscore updated bro");
    }
    // Otherwise, check if the highscore needs to be updated
    else {
        highScore = [[_defaults valueForKey:@"SavedHighScore"] intValue];
        if (_score > highScore) {
            [_defaults setFloat:_score forKey:@"SavedHighScore"];
            NSLog(@"Highscore updated");
        }
    }
    
    [_defaults synchronize];

    return YES;
}


@end
