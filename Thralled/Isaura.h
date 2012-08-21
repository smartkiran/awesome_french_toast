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

@interface Isaura {
    CCNode *IsauraNode;
    b2Body *isaurabody ;
    b2BodyDef isauraBodyDef;
}
+(id) shared;
-(CCNode*)initIsauraAtPosition:(CGPoint) positon inTheWorld:(b2World*) world;

@end
