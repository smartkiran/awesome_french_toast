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
    @public
        CCSprite *isauraSpr;
        CCNode *IsauraNode;
        b2Body *isaurabody ;
        b2BodyDef isauraBodyDef;
}
+(id) shared;
//give the position in pixels..
-(CCNode*) initializeIsauraAtPosition:(CGPoint) positon inTheWorld:(b2World*) world;
-(void)startAnimation:(IsauraAnimationType) animType;
-(void)stopAnimation:(IsauraAnimationType) animType;

@end
