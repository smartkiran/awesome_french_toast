//
//  Isaura.h
//  Thralled
//
//  Created by sai on 8/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

enum IsauraAnimationType{stand_animation,walk_animation};

@interface Isaura:CCLayer {
    @private
        b2Vec2 walkForce;
        bool walkDirection;//true for east and false for west
        bool walk;
        b2Vec2 walkToPosition;
        CCAnimation *walkAnim;
        CCAnimation *standAnim;
}
//@property (nonatomic, retain)  CCAction *walkAnimAction;
//@property (nonatomic, retain) CCAction *standAnimAction;
@property (nonatomic, retain) CCSprite *isauraSpr;
@property (nonatomic, retain) CCNode *IsauraNode;
@property (readwrite, nonatomic)  b2Body *isaurabody;
@property (readwrite, nonatomic)  b2BodyDef isauraBodyDef;

+(id) shared;
//give the position in pixels..
-(CCNode*) initializeIsauraAtPosition:(CGPoint) positon inTheWorld:(b2World*) world;
-(void)startAnimation:(IsauraAnimationType) animType;
-(void)stopAnimation:(IsauraAnimationType) animType;
-(void)moveTo:(CGPoint)poistion;
-(void)isauraStep;
@end
