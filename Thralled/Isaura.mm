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
    walkAnim=[ThralledUtils createAnimationFromPlistFile:@"walking1-14.plist" withDelay:0.25f withName:@"walkAnim"];
    //walkAnimAction=[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim]];
    standAnim=[ThralledUtils createAnimationFromPlistFile:@"standing1-18.plist" withDelay:0.15f withName:@"standAnim"];
    //standAnimAction=[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:standAnim]];
}

-(void)startAnimation:(IsauraAnimationType) animType{
    if(animType==stand_animation)
    {
        [isauraSpr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:standAnim]]];
    }
    else if(animType==walk_animation)
    {
        [isauraSpr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim]]];
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
    walk=YES;
    [[Isaura shared] stopAnimation:stand_animation];
    [[Isaura shared] startAnimation:walk_animation];
    walkToPosition=b2Vec2(position.x/PTM_RATIO,position.y/PTM_RATIO);
    if(isaurabody->GetPosition().x>walkToPosition.x){
        walkForce=b2Vec2(-5,0);
        walkDirection=false;
        isauraSpr.flipX=YES;
    }
    else{
        walkForce=b2Vec2(5,0);
        walkDirection=true; //walking east
        isauraSpr.flipX=NO;
    }
}

-(void)isauraStep{
    if(walk)
    {
        if((walkDirection && isaurabody->GetPosition().x>walkToPosition.x)
           || (!walkDirection && isaurabody->GetPosition().x<walkToPosition.x) )
        {
            isaurabody->SetLinearVelocity(b2Vec2(0,0));
            isaurabody->SetAngularVelocity(0);
            [[Isaura shared] stopAnimation:walk_animation];
            [[Isaura shared] startAnimation:stand_animation];
            walk=false;
        }
        else{
            // clamp velocity
            b2Vec2 velocity =isaurabody->GetLinearVelocity();
           float v = velocity.Length();
            if(v > maxWalkSpeed)
            {
                isaurabody->SetLinearVelocity(maxWalkSpeed/v*velocity);
            }
            isaurabody->ApplyForce(isaurabody->GetMass()* walkForce,walkToPosition);
        }
    }
}

@end
