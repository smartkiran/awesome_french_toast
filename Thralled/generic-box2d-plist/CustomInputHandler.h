//
//  CustomInputHandler.h
//  Thralled
//
//  Created by sai on 8/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum TouchInputType{SINGLE_TAP,DOUBLE_TAP,RIGHT_SWIPE,LEFT_SWIPE,INWARD_PINCH, OUTWARD_PINCH,SINGLE_TAP_HOLD,MULTI_TAP_HOLD,DEFAULT_TOUCH};

@protocol InputHandlerDelegate;

@interface CustomInputHandler : CCLayer {
    @private
        id inputHandlerDelegate;
        TouchInputType touchType;
        CGPoint firstTouchStartLocation;
        CGPoint firstTouchEndLocation;
        CGPoint secondTouchStartLocation;
        CGPoint secondTouchEndLocation;
}
@property (nonatomic, assign) id<InputHandlerDelegate> inputHandlerDelegate;
+(CCScene *) scene;
-(void)setinputHandlerDelegate:(id)caller;
@end

@protocol InputHandlerDelegate
@optional
- (void)singleTapAt:(CGPoint)touchLocation;
- (void)doubleTapAt:(CGPoint)touchLocation;
- (void)slideFrom:(CGPoint)startLocation To:(CGPoint)endLocation;
- (void)leftSlideFrom:(CGPoint)startLocation To:(CGPoint)endLocation;
- (void)rightSlideFrom:(CGPoint)startLocation To:(CGPoint)endLocation;
- (void)pinchFrom:(NSArray*)initialTouchPositions To:(NSArray*)finalTouchPositons;
@end