//
//  CustomInputHandler.m
//  Thralled
//
//  Created by sai on 8/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomInputHandler.h"
#include "ThralledGlobals.h"


@implementation CustomInputHandler
@synthesize inputHandlerDelegate;

- (id)init {
    if (self = [super initWithColor:ccc4(255,255,255,255)]) {
        self.isTouchEnabled=YES;
        self.isAccelerometerEnabled=YES;
    }
    return self;
}

+(CCScene *) scene{
    NSAssert(false, @"you should never hit this assertion. Define the scene method in your class");
    return NULL;
}

-(void)setinputHandlerDelegate:(id)caller{
    inputHandlerDelegate=caller;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    touchType=DEFAULT_TOUCH;
    UITouch *touch = [touches anyObject];
    firstTouchStartLocation = [touch locationInView:[touch view]];
    if (touch.tapCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:[touch view]];
    
    if (fabsf(pow((firstTouchStartLocation.x - currentTouchPosition.x),2)+pow((firstTouchStartLocation.y - currentTouchPosition.y),2)) >= DRAG_MIN)
    {
        
        firstTouchEndLocation=currentTouchPosition;
        // Its a swipe.
        if (firstTouchStartLocation.x < currentTouchPosition.x)
        {
            touchType=RIGHT_SWIPE;
        }
        else
        {
            touchType=LEFT_SWIPE;
        }
    }
    
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touchType==LEFT_SWIPE || touchType==RIGHT_SWIPE)
    {
        firstTouchStartLocation = [[CCDirector sharedDirector] convertToGL: firstTouchStartLocation];
        firstTouchEndLocation= [[CCDirector sharedDirector] convertToGL: firstTouchEndLocation];
        if (inputHandlerDelegate && [inputHandlerDelegate respondsToSelector: @selector(slideFrom: To:)]) {
            [inputHandlerDelegate slideFrom:firstTouchStartLocation To:firstTouchEndLocation];
        }
        if(touchType==LEFT_SWIPE)
        {
            if (inputHandlerDelegate && [inputHandlerDelegate respondsToSelector: @selector(leftSlideFrom: To:)]) {
                [inputHandlerDelegate leftSlideFrom:firstTouchStartLocation To:firstTouchEndLocation];
            }
        }
        else if(touchType==RIGHT_SWIPE)
        {
            if (inputHandlerDelegate && [inputHandlerDelegate respondsToSelector: @selector(rightSlideFrom: To:)]) {
                [inputHandlerDelegate rightSlideFrom:firstTouchStartLocation To:firstTouchEndLocation];
            }
        }
    }
    else
    {
        UITouch *theTouch = [touches anyObject];
        if (theTouch.tapCount == 1) {
            
            CGPoint location = [theTouch locationInView: [theTouch view]];
            location = [[CCDirector sharedDirector] convertToGL: location];
            NSDictionary *touchLoc = [NSDictionary dictionaryWithObject:[NSValue valueWithCGPoint:location] forKey:@"location"];
            [self performSelector:@selector(handleSingleTap:) withObject:touchLoc afterDelay:0.3];
            
        } else if (theTouch.tapCount == 2) {
            touchType=DOUBLE_TAP;
            CGPoint location = [theTouch locationInView: [theTouch view]];
            location = [[CCDirector sharedDirector] convertToGL: location];
            if (inputHandlerDelegate && [inputHandlerDelegate respondsToSelector: @selector(singleTapAt:)]) {
                [inputHandlerDelegate doubleTapAt:location];
            }
        }
    }
    touchType=DEFAULT_TOUCH;
    [self resetPoints];
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //this method is not implemented yet...
    //usually this happens when touches are cancelled by aborting app, minimizing or crashing.. best example is when you get a phone call on iphone..
}

-(void)handleSingleTap:(NSDictionary*) touchLoc{
    CGPoint loc;
    [[touchLoc objectForKey:@"location"] getValue:&loc];
    touchType=SINGLE_TAP;
    if (inputHandlerDelegate && [inputHandlerDelegate respondsToSelector: @selector(singleTapAt:)]) {
        [inputHandlerDelegate singleTapAt:loc];
    }
}

-(void)resetPoints{
    firstTouchEndLocation=CGPointZero;
    firstTouchStartLocation=CGPointZero;
    secondTouchEndLocation=CGPointZero;
    secondTouchStartLocation=CGPointZero;
}

@end
