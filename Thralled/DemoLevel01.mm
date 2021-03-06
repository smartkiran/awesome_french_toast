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
#import "SimpleAudioEngine.h" 

@implementation DemoLevel01
+(CCScene *) scene{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// 'layer' is an autorelease object.
	DemoLevel01 *layer = [DemoLevel01 node];
	[scene addChild: layer];
	return scene;
}

-(id) init{
	if(self=[super init]) {
        windowSize = [CCDirector sharedDirector].winSize;
        //set the delegate
        [self setinputHandlerDelegate:self];
		//enable notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRotated:)
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];
        [self initPhysicsWorld];
        [self initLevel];
		[self scheduleUpdate];
	}
	return self;
}

-(void) initLevel{
    //variable inititalization
    _isauraOnLever=false;
    _isCompleteExchangingLever=false;
    _deltaTime=0;
    isShowingLandscapeView = NO;
    _doorMoveForce=b2Vec2(0, 20);
    _leverMoveForce=b2Vec2(0, -20);
    _doorInitialPosition=b2Vec2(800/PTM_RATIO,200/PTM_RATIO);
    _leverInitialPosition=b2Vec2(300/PTM_RATIO,100/PTM_RATIO);
    _leverCurrentPosition=_leverInitialPosition;
    _doorTargetPosition=b2Vec2(_doorInitialPosition.x,_doorInitialPosition.y+(200/PTM_RATIO));
    _leverTargetPosition=b2Vec2(_leverInitialPosition.x,_leverInitialPosition.y-(200/PTM_RATIO));
    _isauraPreviousPosition=b2Vec2(50/PTM_RATIO, 100/PTM_RATIO);
    _isauraCurrentPosition=_isauraPreviousPosition;
    //creating the parallax background
    CCSprite *backgroundSpr = [CCSprite spriteWithFile:@"Background_2800X780.png"];
    backgroundSpr.scale = 1.0f;
    backgroundSpr.anchorPoint = ccp(0,0);
    _backgroundNode=[CCParallaxNode node];
    [_backgroundNode addChild:backgroundSpr z:-1 parallaxRatio:ccp(1, 1) positionOffset:ccp(0, 0)];
    [self addChild:_backgroundNode];
    
    //creating ground
    CCSprite *sprite = [CCSprite spriteWithFile:@"ground_1080.png"];
    [self addChild:sprite];
    sprite.tag=TAG_GROUND;
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(0,0);
    bodyDef.userData = sprite;
    b2Body *body = _world->CreateBody(&bodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:@"ground_1080"];
    [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"ground_1080"]];
    
    //creating right side wall
    CCSprite *sideWallSpr = [CCSprite spriteWithFile:@"ground_1080.png"];
    [self addChild:sideWallSpr];
    sideWallSpr.tag=TAG_RIGHT_SIDEWALL;
    b2BodyDef sideWallBodyDef;
    sideWallBodyDef.type = b2_staticBody;
    sideWallBodyDef.position.Set(1080/PTM_RATIO,0);
    sideWallBodyDef.userData = sideWallSpr;
    b2Body *sideWallbody = _world->CreateBody(&sideWallBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:sideWallbody forShapeName:@"ground_1080 (2)"];
    [sideWallSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"ground_1080 (2)"]];
    sideWallbody->SetTransform(b2Vec2(1080/PTM_RATIO,0), CC_DEGREES_TO_RADIANS(90.0f));
    sideWallbody->SetGravityScale(0);
    
    //creating left side wall
    CCSprite *lsideWallSpr = [CCSprite spriteWithFile:@"ground_1080.png"];
    [self addChild:lsideWallSpr];
    lsideWallSpr.tag=TAG_LEFT_SIDEWALL;
    b2BodyDef lsideWallBodyDef;
    lsideWallBodyDef.type = b2_staticBody;
    lsideWallBodyDef.position.Set(10/PTM_RATIO,0);
    lsideWallBodyDef.userData = lsideWallSpr;
    b2Body *lsideWallbody = _world->CreateBody(&lsideWallBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:lsideWallbody forShapeName:@"ground_1080 (2)"];
    [lsideWallSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"ground_1080 (2)"]];
    lsideWallbody->SetTransform(b2Vec2(10/PTM_RATIO,0), CC_DEGREES_TO_RADIANS(90.0f));
    lsideWallbody->SetGravityScale(0);
    
    //creating door
    CCSprite *doorSpr = [CCSprite spriteWithFile:@"door.png"];
    [self addChild:doorSpr];
    doorSpr.tag=TAG_DOOR;
    b2BodyDef doorBodyDef;
    doorBodyDef.type = b2_dynamicBody;
    doorBodyDef.position.Set(_doorInitialPosition.x,_doorInitialPosition.y);
    doorBodyDef.userData = doorSpr;
    _doorbody = _world->CreateBody(&doorBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:_doorbody forShapeName:@"door"];
    [doorSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"door"]];
    _doorbody->SetGravityScale(0);
    

    [self addLever];
    //creating isaura from isaura.mm
    [self spawnIsauraAtPosition:_isauraPreviousPosition];    
    
    // Create contact listener
    _contactListener = new MyContactListener();
    _world->SetContactListener(_contactListener);
}

-(void) addNewSpriteAtPosition:(CGPoint)p
{
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
    _deltaX=0;
    _isauraPreviousPosition=_isauraCurrentPosition;
    _isauraCurrentPosition=[[Isaura shared] getIsauraPosition];
    _deltaX=(_isauraPreviousPosition.x-_isauraCurrentPosition.x)*PTM_RATIO;
    CGPoint currentBGNodePosition=[_backgroundNode position];
    CGPoint finalBNPos=ccpAdd(currentBGNodePosition, ccp(_deltaX, 0));
    if(finalBNPos.x<=0){
        [_backgroundNode setPosition:finalBNPos];
        if(_deltaX!=0){
            int sign=_deltaX>0?1:-1;
            _doorbody->SetLinearVelocity(b2Vec2(sign*2, 0));
            _doorbody->ApplyForce(_doorbody->GetMass()* b2Vec2(sign*4, 0),_doorbody->GetWorldCenter());
            if(!_isauraOnLever){
                _leverbody->SetLinearVelocity(b2Vec2(sign*2, 0));
                _leverbody->ApplyForce(_leverbody->GetMass()* b2Vec2(sign*4, 0),_leverbody->GetWorldCenter());
            }
        }
        else{
            _doorbody->SetAngularVelocity(0);
            _doorbody->SetLinearVelocity(b2Vec2(0, _doorbody->GetLinearVelocity().y));
            if(!_isauraOnLever){
                _leverbody->SetAngularVelocity(0);
                _leverbody->SetLinearVelocity(b2Vec2(0, 0));
            }
        }
    }
    else{
        _doorbody->SetAngularVelocity(0);
        _doorbody->SetLinearVelocity(b2Vec2(0, _doorbody->GetLinearVelocity().y));
    }
    _leverCurrentPosition=_leverbody->GetPosition();
	_world->Step(dt, velocityIterations, positionIterations);
    [self doorStep];
    [self leverStep];
    [[Isaura shared]  isauraStep];
    for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
    {
        if (b->GetUserData() != NULL)
        {
            CCSprite *myActor = (CCSprite*)b->GetUserData();
            myActor.position = CGPointMake(b->GetPosition().x * PTM_RATIO,b->GetPosition().y * PTM_RATIO );
            myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    
    std::vector<MyContact>::iterator pos;
    NSLog(@"contacts are :%ld",_contactListener->_contacts.size());
    for(pos = _contactListener->_contacts.begin();pos != _contactListener->_contacts.end()  && !_isCompleteExchangingLever ; ++pos) {
        MyContact contact = *pos;
        if(contact.fixtureA!=NULL && contact.fixtureB!=NULL){
            b2Body *bodyA = contact.fixtureA->GetBody();
            b2Body *bodyB = contact.fixtureB->GetBody();
            if (bodyA!=NULL && bodyB!=NULL && bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
                CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
                CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
                //NSLog(@"tag of A: %d",spriteA.tag);
                //NSLog(@"tag of B: %d",spriteB.tag);
                previousCollision=currentCollision;
                if (spriteA.tag == TAG_ISAURA && (spriteB.tag == TAG_LEFT_SIDEWALL || spriteB.tag==TAG_RIGHT_SIDEWALL || spriteB.tag==TAG_DOOR)) {
                    if(spriteB.tag==TAG_LEFT_SIDEWALL)
                        currentCollision=C_ISAURA_LEFTWALL;
                    else if( spriteB.tag==TAG_RIGHT_SIDEWALL)
                        currentCollision=C_ISAURA_RIGHTWALL;
                    else if(spriteA.tag==TAG_DOOR)
                    {
                        _doorbody->SetAngularVelocity(0);
                        _doorbody->SetLinearVelocity(b2Vec2(0, 0));
                        [self removeFromParentAndCleanup:YES];
                        [[CCDirector sharedDirector] replaceScene: [DemoLevel01 scene]];
                        currentCollision=C_ISAURA_DOOR;
                    }
                    //NSLog(@"first contacted");
                    if(currentCollision!=previousCollision)
                        [[Isaura shared] stopIsaura];
                } else if (spriteB.tag == TAG_ISAURA && (spriteA.tag == TAG_LEFT_SIDEWALL || spriteA.tag==TAG_RIGHT_SIDEWALL|| spriteA.tag==TAG_DOOR)) {
                    if(spriteA.tag==TAG_LEFT_SIDEWALL)
                        currentCollision=C_ISAURA_LEFTWALL;
                    else if( spriteA.tag==TAG_RIGHT_SIDEWALL)
                        currentCollision=C_ISAURA_RIGHTWALL;
                    else if(spriteA.tag==TAG_DOOR){
                        _doorbody->SetAngularVelocity(0);
                        _doorbody->SetLinearVelocity(b2Vec2(0, 0));
                        [self removeFromParentAndCleanup:YES];
                        [[CCDirector sharedDirector] replaceScene: [DemoLevel01 scene]];
                        currentCollision=C_ISAURA_DOOR;
                    }
                    //NSLog(@"second contacted");
                    if(currentCollision!=previousCollision)
                        [[Isaura shared] stopIsaura];
                }
                else if (spriteA.tag == TAG_ISAURA && spriteB.tag == TAG_LEVER) {
                    currentCollision=C_ISAURA_LEVER;
                    if(currentCollision!=previousCollision)
                        [self addIsauraWithLever];
                } else if (spriteB.tag == TAG_ISAURA && spriteA.tag == TAG_LEVER) {
                    currentCollision=C_ISAURA_LEVER;
                    if(currentCollision!=previousCollision)
                        [self addIsauraWithLever];
                }

                else{
                    currentCollision=C_DEFAULT;
                }
            }
        }        
    }
    
    if(_leverTriggered){
        _deltaTime+=1;
        NSLog(@"delta time is %f",_deltaTime);
        if(_deltaTime>maxDoorOpenTime){
            _leverTriggered=false;
            //[self moveDoor:true];
            _moveDoorDown=true;
            _moveDoorUp=false;
            _deltaTime=0;
        }
    }
}

- (void)singleTapAt:(CGPoint)touchLocation{
    NSLog(@"tap received at %f,%f",touchLocation.x,touchLocation.y);
    if(_isauraOnLever){
        //check if tap is on isaura. if yes then bring her down
        b2Fixture *f = _isauraWithLeverBody->GetFixtureList();
        if(f -> TestPoint(b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO))){
            NSLog(@"touched isaura on lever");
            [self removeChild:_isauraNode cleanup:YES];
            [self addLever];
            [self spawnIsauraAtPosition:b2Vec2(_leverCurrentPosition.x+(100/PTM_RATIO), _leverCurrentPosition.y-(40/PTM_RATIO))];
        }
    }
    else{
        touchLocation=ccp(touchLocation.x-150,touchLocation.y);
        [[Isaura shared] moveTo:touchLocation];
    }
}

- (void)doubleTapAt:(CGPoint)touchLocation{
    NSLog(@"double tap received at %f,%f",touchLocation.x,touchLocation.y);
}

- (void)slideFrom:(CGPoint)startLocation To:(CGPoint)endLocation{
    NSLog(@"slide from  %f,%f to %f,%f",startLocation.x,startLocation.y,endLocation.x,endLocation.y);
    [[Isaura shared] jump:startLocation.x];
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

-(void)moveDoor: (bool)down{
    // clamp velocity
    b2Vec2 currentVelocity =_doorbody->GetLinearVelocity();
    float v = currentVelocity.Length();
    if(v > maxDoorSpeed)
    {
        _doorbody->SetLinearVelocity(maxDoorSpeed/v*currentVelocity);
    }
    if(down)
        _doorbody->ApplyForce(_doorbody->GetMass()* (-1)*_doorMoveForce,_doorbody->GetWorldCenter());
    else
        _doorbody->ApplyForce(_doorbody->GetMass()* _doorMoveForce,_doorbody->GetWorldCenter());
}

-(void)doorStep{
    if(_moveDoorUp){
        if(_doorbody->GetPosition().y>=_doorTargetPosition.y){
            _doorbody->SetLinearVelocity(b2Vec2(0, 0));
            _doorbody->SetAngularVelocity(0);
            _moveDoorUp=false;
            _moveDoorDown=true;
        }
        else{
            [self moveDoor:false];
        }
    }
    else if(_moveDoorDown){
        if(_doorbody->GetPosition().y<=_doorInitialPosition.y){
            _doorbody->SetLinearVelocity(b2Vec2(0, 0));
            _doorbody->SetAngularVelocity(0);
            _moveDoorDown=false;
        }
        else{
            [self moveDoor:true];
        }
    }
}

-(void)moveLever: (bool )down{
    // clamp velocity
    b2Vec2 currentVelocity =_leverbody->GetLinearVelocity();
    float v = currentVelocity.Length();
    if(v > maxLeverSpeed)
    {
        _leverbody->SetLinearVelocity(maxLeverSpeed/v*currentVelocity);
    }
    if(down)
        _leverbody->ApplyForce(_leverbody->GetMass()* _leverMoveForce,_leverbody->GetWorldCenter());
    else
        _leverbody->ApplyForce(_leverbody->GetMass()* (-1)*_leverMoveForce,_leverbody->GetWorldCenter());
}

-(void)leverStep{
    if(_moveLeverDown){
        if(_leverbody->GetPosition().y<=_leverTargetPosition.y){
            _leverbody->SetLinearVelocity(b2Vec2(0, 0));
            _leverbody->SetAngularVelocity(0);
            _moveLeverDown=false;
            _moveLeverUp=true;
        }
        else{
            [self moveLever:true];
        }
    }
    else if(_moveLeverUp){
        if(_leverbody->GetPosition().y>=_leverInitialPosition.y){
            _leverbody->SetLinearVelocity(b2Vec2(0, 0));
            _leverbody->SetAngularVelocity(0);
            _moveLeverUp=false;
        }
        else{
            [self moveLever:false];
        }
    }
}

-(void)addIsauraWithLever{
    //first remove the isaura that is already present
    [[Isaura shared] removeIsauraFromWorld:_world];
    [self removeChild:_isauraNode cleanup:YES];
    _isauraOnLever=true;
    //destroy old lever
    _world->DestroyBody(_leverbody);
    //creating lever with isaura
    _isauraWithLeverTex=[[CCTextureCache sharedTextureCache] addImage: @"Lever Pull 25.png"];
    _leverSpr.texture=_isauraWithLeverTex;
    b2BodyDef isauraWithLeverBodyDef;
    isauraWithLeverBodyDef.type = b2_dynamicBody;
    isauraWithLeverBodyDef.position.Set(_leverCurrentPosition.x,_leverCurrentPosition.y);
    isauraWithLeverBodyDef.userData = _leverSpr;
    
    _isauraWithLeverBody = _world->CreateBody(&isauraWithLeverBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:_isauraWithLeverBody forShapeName:@"Lever Pull 25"];
    [_leverSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"Lever Pull 25"]];
    _isauraWithLeverBody->SetGravityScale(0);
    _isCompleteExchangingLever=true;
    //[self moveDoor:false];
    _moveDoorUp=true;
    _leverTriggered=true;
}

-(void)addLever{
    _isauraOnLever=false;
    //creating lever
    _leverTex=[[CCTextureCache sharedTextureCache] addImage: @"Lever 1.png"];
    if(_leverSpr==NULL)
    {
        _leverSpr=[[CCSprite alloc] initWithTexture:_leverTex];
        [self addChild:_leverSpr];
        _leverSpr.tag=TAG_LEVER;
    }
    else
        _leverSpr.texture=_leverTex;
    _leverBodyDef.type = b2_dynamicBody;
    _leverBodyDef.position.Set(_leverCurrentPosition.x,_leverCurrentPosition.y);
    _leverBodyDef.userData = _leverSpr;
    if(_isauraWithLeverBody!=NULL)
        _world->DestroyBody(_isauraWithLeverBody);
    _leverbody = _world->CreateBody(&_leverBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:_leverbody forShapeName:@"Lever 1"];
    [_leverSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"Lever 1"]];
    _leverbody->SetGravityScale(0);
    _isCompleteExchangingLever=false;
}

-(void)spawnIsauraAtPosition:(b2Vec2)position{
    CGPoint pos=ccp(position.x*PTM_RATIO, position.y*PTM_RATIO);
    _isauraNode=[[Isaura shared] initializeIsauraAtPosition:pos inTheWorld:_world];
    [self addChild:_isauraNode];
    [[Isaura shared] startAnimation:stand_animation];
}

@end
