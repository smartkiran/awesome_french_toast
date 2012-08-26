//
//  Isaura.m
//  Thralled
//
//  Created by sai on 8/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Isaura.h"
#include "ThralledGlobals.h"
#import "GB2ShapeCache.h"
#include "ThralledUtils.h"

@implementation Isaura
@synthesize isauraSpr;
@synthesize IsauraNode;
@synthesize isaurabody;
@synthesize isauraBodyDef;
//@synthesize walkAnimAction;
//@synthesize standAnimAction;


+(id) shared{
    static id shared = NULL;
    if(!shared){
        shared = [[Isaura alloc] init];
    }
    return shared;
}

-(id) init
{
    _jumpForce=b2Vec2(15, 40);
    return self;
}

-(CCNode*) initializeIsauraAtPosition:(CGPoint) position inTheWorld:(b2World*) world{
    IsauraNode=[CCNode node];
    //creating isaura
    isauraSpr = [CCSprite spriteWithFile:@"Walking_1.png"];
    [IsauraNode addChild:isauraSpr];
    isauraBodyDef.type = b2_dynamicBody;
    isauraBodyDef.position.Set(position.x/PTM_RATIO,position.y/PTM_RATIO);
    isauraBodyDef.userData = isauraSpr;
    isaurabody = world->CreateBody(&isauraBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:isaurabody forShapeName:@"Walking_1"];
    [isauraSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"Walking_1"]];
    isaurabody->SetFixedRotation(true);
    [self setAnimations];
    return IsauraNode;
}

-(void) setAnimations{
    _walkAnim=[ThralledUtils createAnimationFromPlistFile:@"walking1-14.plist" withDelay:0.25f withName:@"walkAnim"];
    //walkAnimAction=[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim]];
    _standAnim=[ThralledUtils createAnimationFromPlistFile:@"standing1-18.plist" withDelay:0.15f withName:@"standAnim"];
    //standAnimAction=[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:standAnim]];
}

-(void)startAnimation:(IsauraAnimationType) animType{
    if(animType==stand_animation)
    {
        [isauraSpr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_standAnim]]];
    }
    else if(animType==walk_animation)
    {
        [isauraSpr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_walkAnim]]];
    }
}

-(void)stopAnimation:(IsauraAnimationType) animType{
    if(animType==stand_animation)
    {
        [self stopAllAnimations];
    }
    else if(animType==walk_animation)
    {
        [self stopAllAnimations];
    }
}

-(void)stopAllAnimations{
    [isauraSpr stopAllActions];
}

-(void)moveTo:(CGPoint) position{
    isaurabody->SetLinearVelocity(b2Vec2(0,0));
    isaurabody->SetAngularVelocity(0);
    _walk=YES;
    [[Isaura shared] stopAnimation:stand_animation];
    [[Isaura shared] startAnimation:walk_animation];
    _walkToPosition=b2Vec2(position.x/PTM_RATIO,position.y/PTM_RATIO);
    if(isaurabody->GetPosition().x>_walkToPosition.x){
        _walkForce=b2Vec2(-5,0);
        _walkDirection=false;
        isauraSpr.flipX=YES;
    }
    else{
        _walkForce=b2Vec2(5,0);
        _walkDirection=true; //walking east
        isauraSpr.flipX=NO;
    }
}

-(void)jump{
    _jump=true;
    _touchedGround=true;
    _touchingGroundAt=isaurabody->GetPosition();
}

-(void)isauraStep{
    if(_walk)
    {
        if((_walkDirection && isaurabody->GetPosition().x>_walkToPosition.x)
           || (!_walkDirection && isaurabody->GetPosition().x<_walkToPosition.x) )
        {
            isaurabody->SetLinearVelocity(b2Vec2(0,0));
            isaurabody->SetAngularVelocity(0);
            [[Isaura shared] stopAnimation:walk_animation];
            [[Isaura shared] startAnimation:stand_animation];
            _walk=false;
        }
        else{
            // clamp velocity
            b2Vec2 velocity =isaurabody->GetLinearVelocity();
           float v = velocity.Length();
            if(v > maxWalkSpeed)
            {
                isaurabody->SetLinearVelocity(maxWalkSpeed/v*velocity);
            }
            isaurabody->ApplyForce(isaurabody->GetMass()* _walkForce,_walkToPosition);
        }
    }
    else if(_jump)
    {
        if(isaurabody->GetPosition().y>maxJumpInPixels/PTM_RATIO)
        {
            isaurabody->SetLinearVelocity(b2Vec2(1.5,0));
            isaurabody->SetAngularVelocity(0);
            _touchedGround=false;
        }
        else if(!_touchedGround)
        {
            isaurabody->ApplyForce(isaurabody->GetMass()* b2Vec2(1.5, 0),isaurabody->GetWorldCenter());
           if(isaurabody->GetPosition().y<=_touchingGroundAt.y){
                _jump=false;
                isaurabody->SetLinearVelocity(b2Vec2(0,0));
                isaurabody->SetAngularVelocity(0);
            }
        }
        else{
            isaurabody->ApplyForce(isaurabody->GetMass()* _jumpForce,b2Vec2(isaurabody->GetPosition().x, maxJumpInPixels/PTM_RATIO));
        }
    }
}

@end
