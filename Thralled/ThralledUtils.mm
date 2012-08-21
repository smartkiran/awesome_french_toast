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
    if ( dictionary == nil ) {
        NSLog(@"Couldn't load animations from plist file.");
    }
    else {
        NSDictionary *animations = [dictionary objectForKey:@"Root"];
        if ( animations == nil ) {
            CCLOG(@"ISCCAnimationCacheExtensions: No animations found in provided dictionary.");
        }
        else{
                NSArray *frameNames = [animations objectForKey:@"frames"];
                if ( frameNames == nil ) {
                    CCLOG(@"Animation has no frames in plist file: %@", plistFileName);
                }
                else{
                    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:[frameNames count]];
                    for( NSString *frameName in frameNames ) {
                        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
                        if ( frame != nil ) {
                            [frames addObject:frame];
                        }
                    }
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
    }
    return animation;
}

@end
