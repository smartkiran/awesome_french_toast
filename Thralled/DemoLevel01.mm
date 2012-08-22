//
//  DemoLevel01.m
//  Thralled
//
//  Created by sai on 8/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DemoLevel01.h"
#include "ThralledGlobals.h"
#import "PhysicsSprite.h"
#import "GB2ShapeCache.h"
#import "Isaura.h"

@implementation DemoLevel01

+(CCScene *) scene{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	DemoLevel01 *layer = [DemoLevel01 node];
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
    //variable inititalization
    isShowingLandscapeView = NO;
    //creating ground
    CCSprite *sprite = [CCSprite spriteWithFile:@"ground_1080.png"];
    [self addChild:sprite];
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(0,0);
    bodyDef.userData = sprite;
    b2Body *body = _world->CreateBody(&bodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:@"ground_1080"];
    [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"ground_1080"]];
    
    //creating side wall
    CCSprite *sideWallSpr = [CCSprite spriteWithFile:@"ground_1080.png"];
    [self addChild:sideWallSpr];
    b2BodyDef sideWallBodyDef;
    sideWallBodyDef.type = b2_staticBody;
    sideWallBodyDef.position.Set(windowSize.height/PTM_RATIO,0);
    sideWallBodyDef.userData = sideWallSpr;
    b2Body *sideWallbody = _world->CreateBody(&sideWallBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:sideWallbody forShapeName:@"ground_1080"];
    [sideWallSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"ground_1080"]];
    sideWallbody->SetTransform(b2Vec2(windowSize.height/PTM_RATIO,0), CC_DEGREES_TO_RADIANS(90.0f));
    
//    //creating door
//    CCSprite *doorSpr = [CCSprite spriteWithFile:@"door.png"];
//    [self addChild:doorSpr];
//    b2BodyDef doorBodyDef;
//    doorBodyDef.type = b2_staticBody;
//    doorBodyDef.position.Set((2*windowSize.height)/PTM_RATIO/3,100/PTM_RATIO);
//    doorBodyDef.userData = doorSpr;
//    b2Body *doorbody = _world->CreateBody(&doorBodyDef);
//    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:doorbody forShapeName:@"door"];
//    [doorSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"door"]];
    
//    //creating isaura
//    CCSprite *isauraSpr = [CCSprite spriteWithFile:@"Walking_1.png"];
//    [self addChild:isauraSpr];
//    b2BodyDef isauraBodyDef;
//    isauraBodyDef.type = b2_dynamicBody;
//    isauraBodyDef.position.Set(400/PTM_RATIO,100/PTM_RATIO);
//    isauraBodyDef.userData = isauraSpr;
//    isaurabody = _world->CreateBody(&isauraBodyDef);
//    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:isaurabody forShapeName:@"Walking_1"];
//    [isauraSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"Walking_1"]];
//    isaurabody->SetFixedRotation(true);
    
    //creating isaura from isaura.mm
    CCNode *isaura=[[Isaura shared] initializeIsauraAtPosition:ccp(400, 100) inTheWorld:_world];
    [self addChild:isaura];
    [[Isaura shared] startAnimation:stand_animation];
    
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
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	PhysicsSprite *sprite = [PhysicsSprite spriteWithFile:@"ground.png" rect:CGRectMake(0,0,480,20)];
	[self addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	// Define the dynamic body.
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
	fixtureDef.density = 10.0f;
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
	_world->Step(dt, velocityIterations, positionIterations);
    for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
    {
        if (b->GetUserData() != NULL)
        {
            CCSprite *myActor = (CCSprite*)b->GetUserData();
            myActor.position = CGPointMake(b->GetPosition().x * PTM_RATIO,b->GetPosition().y * PTM_RATIO );
            myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
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
        _portraitGravity.Set(0, -10);
        _world->SetGravity(_portraitGravity);
        isShowingLandscapeView = YES;
    }
    
    if (UIDeviceOrientationIsPortrait(deviceOrientation))
    {
        if(deviceOrientation==UIDeviceOrientationPortraitUpsideDown)
        {
            [[Isaura shared] isaurabody] ->SetTransform(b2Vec2(400/PTM_RATIO,30/PTM_RATIO),CC_DEGREES_TO_RADIANS(90));
            _portraitGravity.Set(10, 0);
            NSLog(@"changed to portrait upside down view!");
        }
        else
        {
            NSLog(@"changed to portrait view!");
            _portraitGravity.Set(-10, 0);
        }
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
    [[GB2ShapeCache sharedShapeCache]  addShapesWithFile:@"floor_door_lever_isaura_PE.plist"];
}

@end
