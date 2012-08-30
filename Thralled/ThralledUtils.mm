//
//  ThralledUtils.m
//  Thralled
//
//  Created by sai on 8/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ThralledUtils.h"


@implementation ThralledUtils

+(CCAnimation*) createAnimationFromPlistFile:(NSString *)plistFileName withDelay:(float)delay withName:(NSString*)name{
    CCAnimation* animation = nil;
    NSString *directory = [plistFileName stringByDeletingLastPathComponent];
    NSString *file = [plistFileName lastPathComponent];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:nil inDirectory:directory];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    //NSLog(@"dictionary is %@",dictionary);
    if ( dictionary == nil ) {
        NSLog(@"Couldn't load animations from plist file.");
    }
    else {
        NSArray *frameNames = [dictionary objectForKey:@"frames"];
        if ( frameNames == nil ) {
            CCLOG(@"Animation has no frames in plist file: %@", plistFileName);
        }
        else{
            NSMutableString *textureFileName=[NSMutableString stringWithString:plistFileName];
            [textureFileName deleteCharactersInRange: [textureFileName rangeOfString: @".plist"]];
            [textureFileName appendString:@".png"];
             //NSLog(@"plist is %@, png is %@",plistFileName,textureFileName);
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plistFileName textureFilename:textureFileName];
            NSMutableArray *frames = [NSMutableArray arrayWithCapacity:[frameNames count]];
            for( NSString *frameName in frameNames ) {
                CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
                if ( frame != nil ) {
                    [frames addObject:frame];
                }
            }
            //NSLog(@"dictionary is %@",frames);
            if ( [frames count] == 0 ) {
                CCLOG(@"Animation failed to add to animationCache for plist file %@",plistFileName);
            }
            else if ( [frames count] != [frameNames count] ) {
                CCLOG(@"Some or all of the frames for the animation may be missing for plist file %@",plistFileName);
            }
            if ( delay >= 0.0f ) {
                animation = [CCAnimation animationWithSpriteFrames:frames delay:delay];
            } else {
                animation = [CCAnimation animationWithSpriteFrames:frames];
            }
            [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:name];
        }
    }
    return animation;
}

+(void)restartGame{
//    [self removeFromParentAndCleanup:YES];
//	[[CCDirector sharedDirector] replaceScene: [HelloWorld scene]];

}

@end
