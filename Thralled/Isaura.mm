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
    _jumpForce=b2Vec2(10, 30);
    _counterJumpForce=b2Vec2(20, -40);
    _isFallAnimPlayed=true;
    return self;
}

-(CCNode*) initializeIsauraAtPosition:(CGPoint) position inTheWorld:(b2World*) world{
    IsauraNode=[CCNode node];
    //creating isaura
    isauraSpr = [CCSprite spriteWithFile:@"Walking_1.png"];
    [IsauraNode addChild:isauraSpr];
    isauraSpr.tag=TAG_ISAURA;
    isauraBodyDef.type = b2_dynamicBody;
    isauraBodyDef.position.Set(position.x/PTM_RATIO,position.y/PTM_RATIO);
    isauraBodyDef.userData = isauraSpr;
    isaurabody = world->CreateBody(&isauraBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:isaurabody forShapeName:@"Walking_1"];
    [isauraSpr setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"Walking_1"]];
    isaurabody->SetFixedRotation(true);
    [self setAnimations];
    _isAlive=true;
    _walk=false;
    _jump=false;
    return IsauraNode;
}

-(void) setAnimations{
    _walkAnim=[ThralledUtils createAnimationFromPlistFile:@"walking1-14.plist"
                                                withDelay:0.25f withName:@"walkAnim"];
    _standAnim=[ThralledUtils createAnimationFromPlistFile:@"standing1-18.plist"
                                                 withDelay:0.15f withName:@"standAnim"];
    _runAnim=[ThralledUtils createAnimationFromPlistFile:@"run1-16.plist"
                                               withDelay:0.15f withName:@"runAnim"];
    _jumpAnim=[ThralledUtils createAnimationFromPlistFile:@"jumping1-4.plist"
                                                withDelay:0.4f withName:@"jumpAnim" ];
    _landingAnim=[ThralledUtils createAnimationFromPlistFile:@"landing1-20.plist"
                                                   withDelay:0.15f withName:@"landingAnim"];
    _fallAnim=[ThralledUtils createAnimationFromPlistFile:@"falling1-12.plist"
                                                withDelay:0.05f withName:@"fallAnim"];
}

-(void)startAnimation:(IsauraAnimationType) animType{
    if(!_isAlive)
        return;
    if(animType==stand_animation){
        [isauraSpr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_standAnim]]];
    }
    else if(animType==walk_animation){
        [isauraSpr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_walkAnim]]];
    }
    else if(animType==landing_animation){
        [isauraSpr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_landingAnim]]];
    }
    else if(animType==run_animation){
        [isauraSpr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_runAnim]]];
    }
    else if(animType==jump_animation){
        _jumpAnim.restoreOriginalFrame=FALSE;
        [isauraSpr runAction:[CCAnimate actionWithAnimation:_jumpAnim] ];
    }
    else if(animType==fall_animation){
        [isauraSpr runAction:[CCAnimate actionWithAnimation:_fallAnim]];
    }
}

-(void)stopAnimation:(IsauraAnimationType) animType{
    if(!_isAlive)
        return;
    if(animType==stand_animation)
    {
        [self stopAllAnimations];
    }
    else if(animType==walk_animation)
    {
        [self stopAllAnimations];
    }
    else{
        [self stopAllAnimations];
    }
}

-(void)stopAllAnimations{
    if(!_isAlive)
        return;
    [isauraSpr stopAllActions];
}

-(void)moveTo:(CGPoint) position{
    if(!_isAlive)
        return;
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
    if(!_isAlive)
        return;
    _jump=true;
    _touchedGround=true;
    _touchingGroundAt=isaurabody->GetPosition();
    [self startAnimation:jump_animation];
}

-(void)isauraStep{
    if(!_isAlive)
        return;
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
            isaurabody->SetLinearVelocity(b2Vec2(0,0));
            isaurabody->SetAngularVelocity(0);
            _touchedGround=false;
            _isFallAnimPlayed=false;
        }
        else if(!_touchedGround)
        {
            [self playFallingAnimation];
            isaurabody->ApplyForce(isaurabody->GetMass()* _counterJumpForce,isaurabody->GetWorldCenter());
           if(isaurabody->GetPosition().y<=_touchingGroundAt.y){
                _jump=false;
                isaurabody->SetLinearVelocity(b2Vec2(0,0));
                isaurabody->SetAngularVelocity(0);
               [self startAnimation:stand_animation];
            }
        }
        else{
            isaurabody->ApplyForce(isaurabody->GetMass()* _jumpForce,b2Vec2(isaurabody->GetPosition().x, maxJumpInPixels/PTM_RATIO));
        }
    }
}

-(void) playFallingAnimation{
    if(!_isAlive)
        return;
    if(!_isFallAnimPlayed){
        _isFallAnimPlayed=true;
        [self stopAllAnimations];
        [self startAnimation:fall_animation];
    }
}

-(b2Vec2)getIsauraPosition{
    if(_isAlive)
        return isaurabody->GetPosition();
    else
        return b2Vec2(0, 0);
}

-(void)stopIsaura{
    if(!_isAlive)
        return;
    isaurabody->SetLinearVelocity(b2Vec2(0,0));
    isaurabody->SetAngularVelocity(0);
    _jump=false;
    _walk=false;
    [self stopAllAnimations];
    [self startAnimation:stand_animation];
}

-(void)removeIsauraFromWorld:(b2World*) world{
    world->DestroyBody(isaurabody);
    _isAlive=false;
}

@end
