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
        CCAction *walkAnimAction;
        CCAction *standAnimAction;
}
@property (nonatomic, retain) CCSprite *isauraSpr;
@property (nonatomic, retain) CCNode *IsauraNode;
@property (readwrite, nonatomic)  b2Body *isaurabody;
@property (readwrite, nonatomic)  b2BodyDef isauraBodyDef;

+(id) shared;
//give the position in pixels..
-(CCNode*) initializeIsauraAtPosition:(CGPoint) positon inTheWorld:(b2World*) world;
-(void)startAnimation:(IsauraAnimationType) animType;
-(void)stopAnimation:(IsauraAnimationType) animType;

@end
