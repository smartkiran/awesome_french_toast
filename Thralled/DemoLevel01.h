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
    
@interface DemoLevel01 : CCLayer {
    CCTexture2D *spriteTexture_;
    CGSize windowSize;
    bool isShowingLandscapeView ;
    b2World *_world;
    b2Body *_body ;
    CCSprite *_ball ;
    b2Vec2 _portraitGravity;
    //b2Body *isaurabody ;
}
+(CCScene *) scene;

@end
