//
//  DemoLevel.m
//  Thralled
//
//  Created by sai on 8/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DemoLevel.h"
#include "ThralledGlobals.h"
#import "PhysicsSprite.h"

@implementation DemoLevel

+(CCScene *) scene{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	DemoLevel *layer = [DemoLevel node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		windowSize = [CCDirector sharedDirector].winSize;
		// enable events
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		//enable notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceRotated:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        [self initPhysicsWorld];
        [self initLevel];
		[self scheduleUpdate];
	}
	return self;
}

-(void) initLevel{
    CCNode *parent = [CCNode node];
    //variable inititalization
    isShowingLandscapeView = NO;
    
    
    spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"ground.png"];
    [self addChild:parent z:0 tag:1];
    //create the ground
    PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(0,0,480,20)];
	[parent addChild:sprite];
	sprite.position = ccp( windowSize.height/2, 20);
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(windowSize.height/PTM_RATIO/2,10/PTM_RATIO);
    b2Body *body = _world->CreateBody(&bodyDef);
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(windowSize.height/PTM_RATIO/2, 10.0f/PTM_RATIO);
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	body->CreateFixture(&fixtureDef);
	[sprite setPhysicsBody:body];
   // [self createBallAt:ccp(400, 100)];

    [self addNewSpriteAtPosition:ccp(windowSize.height/2, windowSize.width/2)];
    //[self addNewSpriteAtPosition:ccp(windowSize.height/2, windowSize.width)];
    //[self addNewSpriteAtPosition:ccp(windowSize.height/2, windowSize.width*2)];
    //[self schedule:@selector(tick:)];
}

-(void) createBallAt:(CGPoint)position{
    //create the ball
    _ball=[CCSprite spriteWithFile:@"Ball.jpg" rect:CGRectMake(0, 0, 52, 52)];
    _ball.position=position;
    [self addChild:_ball];
    b2BodyDef ballDef;
    ballDef.position.Set(position.x/PTM_RATIO , position.y/PTM_RATIO);
    ballDef.type=b2_dynamicBody;
    ballDef.userData=_ball;
    _body=_world->CreateBody(&ballDef);
    b2CircleShape ballShape;
    ballShape.m_radius=26/PTM_RATIO;
    b2FixtureDef ballFixture;
    ballFixture.shape=&ballShape;
    ballFixture.density=1.0f;
    ballFixture.friction=0.3f;
    ballFixture.restitution=0.8f;
    _body->CreateFixture(&ballFixture);
}
-(void) addNewSpriteAtPosition:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCNode *parent = [self getChildByTag:1];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
    CCSprite *temp=[CCSprite spriteWithFile:@"ground.png"];
    PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(0,0,480,20)];
	[parent addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    NSLog(@"p.x/PTM_RATIO, p.y/PTM_RATIO : %f ,%f",p.x/PTM_RATIO/2, p.y/PTM_RATIO/2);
	b2Body *body = _world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(480.0f/PTM_RATIO/2, 20.0f/PTM_RATIO/2);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	[sprite setPhysicsBody:body];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    delete _world;
    _body = NULL;
    _world = NULL;
	[super dealloc];
}

-(void) draw
{
	[super draw];
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	kmGLPushMatrix();
	_world->DrawDebugData();
	kmGLPopMatrix();
}

-(void) update: (ccTime) dt
{
	//NSLog(@"update called");
    _world->Step(dt, velocityIterations, positionIterations);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *ballData = (CCSprite *)b->GetUserData();
            ballData.position = ccp(b->GetPosition().x * PTM_RATIO,
                                    b->GetPosition().y * PTM_RATIO);
            ballData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteAtPosition: location];
	}
}

- (void) deviceRotated:(NSNotification *) notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    windowSize = [CCDirector sharedDirector].winSize;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
         NSLog (@"changed to landscape view!");
        isShowingLandscapeView = YES;
    }
    
    if (UIDeviceOrientationIsPortrait(deviceOrientation))
    {
        NSLog(@"changed to portrait view!");
        _portraitGravity.Set(-10, 0);
        if(deviceOrientation==UIDeviceOrientationPortraitUpsideDown)
            _portraitGravity.Set(10, 0);
        _world->SetGravity(_portraitGravity);
        isShowingLandscapeView = NO;
    }
}

-(void) initPhysicsWorld{
    //creating the world
    b2Vec2 gravity=b2Vec2(0, -10); //so gravity is 10m/s2
    _world=new b2World(gravity);
    _world->SetAllowSleeping(true);
    _world->SetContinuousPhysics(true);

}

@end
