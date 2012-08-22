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

+(id) shared{
    static id shared = NULL;
    if(!shared){
        shared = [[Isaura alloc] init];
    }
    return shared;
}

-(id) init
{
    //left this method for any custom initalization
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
    CCAnimation *walkAnim=[ThralledUtils createAnimationFromPlistFile:@"walking.plist" withDelay:1.0f withName:@"walkAnim"];
    walkAnimAction=[CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:walkAnim]];
    CCAnimation *standAnim=[ThralledUtils createAnimationFromPlistFile:@"standing.plist" withDelay:1.0f withName:@"standAnim"];
    standAnimAction=[CCRepeatForever actionWithAction:
                    [CCAnimate actionWithAnimation:standAnim]];
}

-(void)startAnimation:(IsauraAnimationType) animType{
    if(animType==stand_animation)
    {
        [isauraSpr runAction:standAnimAction];
    }
    else if(animType==walk_animation)
    {
        [isauraSpr runAction:walkAnimAction];
    }
}

-(void)stopAnimation:(IsauraAnimationType) animType{
    if(animType==stand_animation)
    {
        [isauraSpr stopAction:standAnimAction];
    }
    else if(animType==walk_animation)
    {
        [isauraSpr stopAction:walkAnimAction];
    }
}

-(void)stopAllAnimations{
    [isauraSpr stopAllActions];
}

@end
