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

+(id) shared{
    static id shared = NULL;
    if(!shared){
        shared = [Isaura init];
    }
    return shared;
}

-(id) init
{
    //left this method for any custom initalization
    return self;
}

-(CCNode*) initIsauraAtPosition:(CGPoint) position inTheWorld:(b2World*) world{
    IsauraNode=[CCNode node];
    //creating isaura
    CCSprite *isauraSpr = [CCSprite spriteWithFile:@"Walking_1.png"];
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
    CCAnimation *walkAnim=[ThralledUtils createAnimationFromPlistFile:@"Walking.plist" withDelay:1.0f withName:@"walkAnim"];
}

@end
