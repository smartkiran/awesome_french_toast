//
//  DemoLevel01.h
//  Thralled
//
//  Created by sai on 8/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CustomInputHandler.h"
#include "MyContactListener.h"

enum collisionTags{
    C_ISAURA_RIGHTWALL=0,
    C_ISAURA_LEFTWALL=1,
    C_ISAURA_GROUND=2,
    C_ISAURA_DOOR=3,
    C_ISAURA_LEVER=4,
    C_DEFAULT=5
};

@interface DemoLevel01 : CustomInputHandler <InputHandlerDelegate>{
    CCTexture2D *spriteTexture_;
    CGSize windowSize;
    bool isShowingLandscapeView ;
    b2World *_world;
    b2Body *_body ;
    b2Body *_doorbody;
    b2Body *_leverbody;
    b2Body *_isauraWithLeverBody;
    CCSprite *_ball ;
    CCSprite *_leverSpr;
    CCTexture2D *_isauraWithLeverTex;
    CCTexture2D *_leverTex;
    b2BodyDef _leverBodyDef;
    b2Vec2 _portraitGravity;
    b2Vec2 _doorMoveForce;
    b2Vec2 _leverMoveForce;
    bool _moveDoorUp;
    bool _moveLeverDown;
    bool _moveDoorDown;
    bool _moveLeverUp;
    bool _isauraOnLever;
    float _distanceToMoveDoor;
    float _distanceToMoveLever;
    bool _isCompleteExchangingLever;
    bool _leverTriggered;
    b2Vec2 _doorInitialPosition;
    b2Vec2 _leverInitialPosition;
    b2Vec2 _leverCurrentPosition;
    b2Vec2 _doorTargetPosition;
    b2Vec2 _leverTargetPosition;
    CCNode *_isauraNode;
    CCParallaxNode *_backgroundNode;
    MyContactListener *_contactListener;
    
    //track isaura positions for scrolling background
    b2Vec2 _isauraPreviousPosition;
    b2Vec2 _isauraCurrentPosition;
    float _deltaX;
    
    collisionTags currentCollision;
    collisionTags previousCollision;
    
    float _deltaTime;
}
+(CCScene *) scene;
- (void)singleTapAt:(CGPoint)touchLocation;

@end
