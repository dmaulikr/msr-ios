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
#import "Powerup.h"

// -----------------------------------------------------------------------
#pragma mark - GameScene
// -----------------------------------------------------------------------
const int MAX_MISSILES = 4;
bool DEBUGbool = false;
const int BACKGROUND_SCROLL_SPEED = 4;
bool playAccel = false;
bool gameRunning = false;
bool inIntroScene = false;

@implementation GameScene
{
    CCSprite *_background1;
    CCSprite *_background2;
    CCSprite *_ship;
    CCPhysicsNode *_physicsWorld;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_introLabel;
    CCButton *_playGame;
    Player *_martian;
    Missile *_missile;
    Powerup *_powerup;
    CCLayoutBox *endMenu;
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
    [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(getValues:) userInfo:nil repeats:YES];
    self.manager.accelerometerUpdateInterval = 0.05;
    [self.manager startAccelerometerUpdates];
    
    // Add images as backgrounds
    _background1 = [CCSprite spriteWithImageNamed:@"skybackground.png"];
    _background1.position = CGPointMake(10,0);
    [self addChild:_background1 z:-3];
    
    _background2 = [CCSprite spriteWithImageNamed:@"skybackground2.png"];
    _background2.position = CGPointMake(10,0);
    [self addChild:_background2 z:-3];
    [self schedule:@selector(introClouds:) interval:1.0]; // Animating sideways clouds
    
    // Spaceship
    CCAction *waverUp = [CCActionMoveTo actionWithDuration:0.8 position:CGPointMake(0.5f, 0.63f)];
    CCAction *waverDown = [CCActionMoveTo actionWithDuration:0.8 position:CGPointMake(0.5f, 0.58f)];
    _ship = [CCSprite spriteWithImageNamed:@"ship.png"];
    _ship.positionType = CCPositionTypeNormalized;
    _ship.position = ccp(0.5f, 0.6f);
    [self addChild:_ship z:1];
    [_ship runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actionWithArray:@[waverDown, waverUp]]]];
    //turn intro scene bool on
    inIntroScene = true;
    
    // Intro title
    _introLabel = [CCLabelTTF labelWithString: NSLocalizedString(@"Martian Fall", nil) fontName:@"Chalkduster" fontSize:36.0f];
    _introLabel.positionType = CCPositionTypeNormalized;
    _introLabel.color = [CCColor redColor];
    _introLabel.position = ccp(0.5f, 0.8f); // Middle of screen
    [self addChild: _introLabel];
    
    // Play button
    _playGame = [CCButton buttonWithTitle: NSLocalizedString(@"Tap to begin", nil) fontName:@"Verdana-Bold" fontSize:18.0f];
    _playGame.positionType = CCPositionTypeNormalized;
    _playGame.position = ccp(0.5f, 0.35f);
    [_playGame setTarget:self selector:@selector(initGame)];
    [self addChild:_playGame];
    
	return self;
}

- (void)initGame {
    inIntroScene = false;
    
     // Fade out buttons
    [_introLabel runAction:[CCActionFadeOut actionWithDuration:0.4]];
    [self removeChild:_playGame];
    
     // Set up the physics world
     _physicsWorld = [CCPhysicsNode node];
     _physicsWorld.gravity = ccp(0,0);
     _physicsWorld.debugDraw = NO; //for debug put yes
     _physicsWorld.collisionDelegate = self;
     [self addChild:_physicsWorld z:-1];
    
     // Player
     _martian = [[Player alloc] initWorld:_physicsWorld withPosition:_ship.positionInPoints andScene:self];
     [self removeChild:_ship];
    
     // Init and alloc mutable missile array
     _missilesArray = [[NSMutableArray alloc] init];
    
    // Create a accelorometer button for testing
    CCButton *accelButton = [CCButton buttonWithTitle:NSLocalizedString(@"[ Accelerometer ]", nil) fontName:@"Verdana-Bold" fontSize:14.0f];
    accelButton.positionType = CCPositionTypeNormalized;
    accelButton.position = ccp(0.79f, 0.90f); // Top Right of screen
    [accelButton setTarget:self selector:@selector(toggleAccel:)];
    [self addChild:accelButton];
     
    // Initialize the score & its label
    _score = 0;
    _scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",_score] fontName:@"Chalkduster" fontSize:14.0f];
    _scoreLabel.positionType = CCPositionTypeNormalized;
    _scoreLabel.color = [CCColor blackColor];
    _scoreLabel.position = ccp(0.15f, 0.95f); // Top right corner
    [self addChild:_scoreLabel];
    
     // Schedule upwards clouds & sky
    [self unschedule:@selector(introClouds:)];
    [self schedule:@selector(addCloud:) interval:1.5];
    [self schedule:@selector(moveBackground:) interval:0.03];

    //End of game menu, created now but added only at end of game
    // Create a playAgain button for end of game
    CCButton *playAgainButton = [CCButton buttonWithTitle:NSLocalizedString(@"[ Play ]", nil) fontName:@"Verdana-Bold" fontSize:20.0f];
    [playAgainButton setTarget:self selector:@selector(onPlayAgainClick:)];
    
    //make twitter button
    CCSpriteFrame *weiboFrame = [CCSpriteFrame frameWithImageNamed:@"weibo2.png"];
    CCButton *weiboB = [CCButton buttonWithTitle:@" " spriteFrame:weiboFrame];
    [weiboB setTarget:self selector:@selector(onWeiboClick:)];

    //make facebook button
    CCSpriteFrame *facebookFrame = [CCSpriteFrame frameWithImageNamed:@"facebook.png"];
    CCButton *facebookB = [CCButton buttonWithTitle:@" " spriteFrame:facebookFrame];
    [facebookB setTarget:self selector:@selector(onFacebookClick:)];
    
    //make twitter button
    CCSpriteFrame *twitterFrame = [CCSpriteFrame frameWithImageNamed:@"twitterSmall.png"];
    CCButton *twitterB = [CCButton buttonWithTitle:@" " spriteFrame:twitterFrame];
    [twitterB setTarget:self selector:@selector(onTwitterClick:)];
    
    //highscore label
    int highScore = [self calculateHighScore];
    CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"High score: %d", highScore] fontName:@"Chalkduster" fontSize:14.0f];
    highScoreLabel.positionType = CCPositionTypeNormalized;
    highScoreLabel.color = [CCColor blackColor];
    //_scoreLabel.position = ccp(0.15f, 0.95f); // Top left corner
    [self addChild:highScoreLabel];
    
    endMenu = [[CCLayoutBox alloc] init];
    endMenu.direction = CCLayoutBoxDirectionVertical;
    endMenu.spacing = 10.f;
    endMenu.position = CGPointMake((self.contentSize.width/2 - (playAgainButton.contentSize.width/2)),(self.contentSize.height/2 - (playAgainButton.contentSize.height * 2)));
    //endMenu.positionType = CCPositionTypeNormalized;
    //endMenu.position = ccp(0.85f, 0.95f);
    [endMenu addChild:weiboB];
    [endMenu addChild:facebookB];
    [endMenu addChild:twitterB];
    [endMenu addChild:playAgainButton];
    
    //start the gameRunning
    gameRunning = true;
     
     // Initialize the highscore table
     _defaults = [NSUserDefaults standardUserDefaults];
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
    [self schedule:@selector(addMissile:) interval:2];
    [self schedule:@selector(incrementScore) interval:0.1];
    [self schedule:@selector(addPowerup:) interval:4.5];
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

- (void)introClouds:(CCTime)dt {
    CCSprite *cloud = [CCSprite spriteWithImageNamed:@"cloud.png"];
    [cloud setName:@"cloud"];

    // Set time and space bounds for cloud generation
    int maxY = self.contentSize.height;
    int randomY = (arc4random() % maxY);
    int minDuration = 2.0;
    int maxDuration = 3.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    cloud.position = CGPointMake(self.contentSize.width, randomY);
    [self addChild:cloud z:-2];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(0 - cloud.contentSize.width, randomY)];
    CCAction *actionRemove = [CCActionRemove action];
    [cloud runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
}

- (void)addCloud:(CCTime)dt {
    CCSprite *cloud = [CCSprite spriteWithImageNamed:@"cloud.png"];
    
    // Set time and space bounds for cloud generation
    int maxX = self.contentSize.width;
    int randomX = (arc4random() % maxX);
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    cloud.position = CGPointMake(randomX, 0);
    [self addChild:cloud z:-2];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(randomX, self.contentSize.height + cloud.contentSize.height)];
    CCAction *actionRemove = [CCActionRemove action];
    [cloud runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
    
}

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Scoring
// -----------------------------------------------------------------------

- (void)incrementScore
{
    if (gameRunning == true) {
        _score++;
        [_scoreLabel setString:[NSString stringWithFormat:NSLocalizedString(@"Score: %03d", nil), _score]];
    }
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (playAccel == false) {
        CGPoint touchLoc = [touch locationInNode:self];
    
        // Log touch location
        CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    
        // Move our sprite to touch location
        CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.4f position:touchLoc];
        [_martian._sprite runAction:actionMove];
    }
    //make it so if you tap anywhere on screen while on intro scene and the game begins
    if (inIntroScene == true) {
        [self initGame];
    }
}
// -----------------------------------------------------------------------
#pragma mark - Accelerometer movement
// -----------------------------------------------------------------------
-(void) getValues:(NSTimer *) timer {
    //NSLog(@"Position: %f %f", _martian._sprite.position.x, _martian._sprite.position.y);
    
    if (playAccel == true) {

        float accelX = self.manager.accelerometerData.acceleration.x * 15;
        float accelY = self.manager.accelerometerData.acceleration.y;
        
        // Adjust so player doesn't have to tilt so much to go upwards
        if (accelY > 0) {
            accelY *= 25;
        }
        else accelY *= 13;
        
        CGPoint newAccel = CGPointMake(accelX, accelY);
        CGPoint newVel = CGPointMake(_martian.physicsBody.surfaceVelocity.x + newAccel.x,
                                     _martian.physicsBody.surfaceVelocity.y + newAccel.y);
    
        [_martian.physicsBody setSurfaceVelocity:newVel];
        
        CGPoint touchLoc = CGPointMake (_martian._sprite.position.x + newVel.x,
                                        _martian._sprite.position.y + newVel.y);

        touchLoc = [self playerBoundBox:touchLoc];
        CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.02f position:touchLoc];
        
        [_martian._sprite runAction:actionMove];
    }
}
// -----------------------------------------------------------------------
#pragma mark - Bounding box for player function - make sure player stays on screen
// -----------------------------------------------------------------------
-(CGPoint)playerBoundBox:(CGPoint) playerLoc {
    int padding = 5;
    float extra = 0;
    //check x coordinates
    if (playerLoc.x > (self.contentSize.width + padding)) {
        extra = playerLoc.x - (self.contentSize.width + padding);
        playerLoc.x = playerLoc.x - extra;
    } else if (playerLoc.x < -10) {
        playerLoc.x = -10;
    }

    //check y coordinates, keep y coords in top 2/3 of screen
    if (playerLoc.y > (self.contentSize.height + padding)) {
        extra = playerLoc.y - (self.contentSize.height + padding);
        playerLoc.y = playerLoc.y - extra;
    } else if (playerLoc.y < (self.contentSize.height/3)) {
        playerLoc.y = (self.contentSize.height/3);
    }
    
    return playerLoc;
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
- (void)onPlayAgainClick:(id)sender
{
    //transition to begin of this scene again
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]
                               withTransition:[CCTransition transitionCrossFadeWithDuration:0.8f]];

}
// -----------------------------------------------------------------------
#pragma mark - Social Media Sharing Functions
// -----------------------------------------------------------------------

- (void)onTwitterClick:(id)sender
{
    NSString *shareMessage = [NSString stringWithFormat:NSLocalizedString(@"I just scored %d in #MartianFall. Play for yourself at ", nil), _score];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText: shareMessage];
        [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        CCLabelTTF *twitterMessage = [CCLabelTTF labelWithString:NSLocalizedString(@"No Twitter account found.",nil) fontName:@"Verdana-Bold" fontSize:18.0f];
        twitterMessage.positionType = CCPositionTypeNormalized;
        twitterMessage.position = ccp(0.5f, 0.8f); // Middle of screen
        [self addChild: twitterMessage];
        CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:2.0];
        CCAction *actionRemove = [CCActionRemove action];
        [twitterMessage runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    }
}

- (void)onFacebookClick:(id)sender
{
    NSString *shareMessage = [NSString stringWithFormat:NSLocalizedString(@"I just scored %d in #MartianFall. Play for yourself at ", nil), _score];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeFacebook];
        [tweetSheet setInitialText: shareMessage];
        [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        CCLabelTTF *fbMessage = [CCLabelTTF labelWithString:NSLocalizedString(@"No Facebook account found.", nil) fontName:@"Verdana-Bold" fontSize:18.0f];
        fbMessage.positionType = CCPositionTypeNormalized;
        fbMessage.position = ccp(0.5f, 0.8f); // Middle of screen
        [self addChild: fbMessage];
        CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:2.0];
        CCAction *actionRemove = [CCActionRemove action];
        [fbMessage runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    }
}

- (void)onWeiboClick:(id)sender
{
    NSString *shareMessage = [NSString stringWithFormat:NSLocalizedString(@"I just scored %d in #MartianFall. Play for yourself at ", nil), _score];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]){
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        [tweetSheet setInitialText: shareMessage];
        [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        CCLabelTTF *weiboMessage = [CCLabelTTF labelWithString:NSLocalizedString(@"No Weibo account found.", nil) fontName:@"Verdana-Bold" fontSize:18.0f];
        weiboMessage.positionType = CCPositionTypeNormalized;
        weiboMessage.position = ccp(0.5f, 0.8f); // Middle of screen
        [self addChild: weiboMessage];
        CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:2.0];
        CCAction *actionRemove = [CCActionRemove action];
        [weiboMessage runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    }
}
- (void)toggleAccel:(id)sender {
    playAccel = !playAccel;
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
#pragma mark - Collision Detection for Missiles
// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair missileCollision:(CCNode *)missile playerCollision:(CCNode *)player {
        
    CCSprite *boomer = [CCSprite spriteWithImageNamed:(@"boomer.png")];
    CGPoint new_pos = missile.position;
    new_pos.y = new_pos.y + 10;
    boomer.position  = new_pos;
    [self addChild:boomer z:-1];

    [missile removeFromParent];
    [player removeFromParent];
    
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:2.0];
    CCAction *actionRemove = [CCActionRemove action];
    [boomer runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];

    //stop the score & control scheme
    gameRunning = false;
    playAccel = false;
    

    
    //create end menu
    [self addChild:endMenu];
    
    return YES;
}


// -----------------------------------------------------------------------
#pragma mark - High Score Calculation and Storing
// -----------------------------------------------------------------------

-(int) calculateHighScore {
    /* HIGHSCORE MANAGEMENT */
    int highScore = _score;
    
    // If the app is running for the first time, set the high score
    if (![_defaults objectForKey:@"firstRun"]) {
        [_defaults setObject:[NSDate date] forKey:@"firstRun"];
        [_defaults setFloat:_score forKey:@"SavedHighScore"];
        NSLog(@"Highscore updated bro");
        [_defaults synchronize];
        
        return highScore;
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
    return highScore;
    
}
// -----------------------------------------------------------------------
#pragma mark - Add Powerup
// -----------------------------------------------------------------------
-(void)addPowerup:(CCTime)delta
{
    _powerup = [[Powerup alloc] initWithPhysicsWorld: _physicsWorld andGameScene:self];
}
// -----------------------------------------------------------------------
#pragma mark - Collision Detection for Powerups and player
// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair powerupCollision:(CCNode *)powerup playerCollision:(CCNode *)player {
    
    CCSprite *pUp = [CCSprite spriteWithImageNamed:(@"fireworks.png")];
    CGPoint new_pos = powerup.position;
    new_pos.y = new_pos.y + 10;
    pUp.position  = new_pos;
    [self addChild:pUp z:-2];
    
    [powerup removeFromParent];
    
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:1.0];
    CCAction *actionRemove = [CCActionRemove action];
   
    [pUp runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    return YES;
}
// -----------------------------------------------------------------------
#pragma mark - Collision Detection for Powerups and missiles
// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair missileCollision:(CCNode *)missile powerupCollision:(CCNode *)powerup {
    
    CCSprite *boomer = [CCSprite spriteWithImageNamed:(@"fireworks.png")];
    CGPoint new_pos = missile.position;
    new_pos.y = new_pos.y + 10;
    boomer.position  = new_pos;
    [self addChild:boomer z:-1];
    
    [missile removeFromParent];
    [powerup removeFromParent];
    
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:1.0];
    CCAction *actionRemove = [CCActionRemove action];
    
    [boomer runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    
    return YES;
}

@end
