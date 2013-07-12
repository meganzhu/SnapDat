//
//  CCDirector+PopTransition.m
//  Ghost
//
//  Created by Brian Chu on 1/9/13.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "CCDirector+PopTransition.h"

@implementation CCDirector (PopTransition)

//method that enables us to pop a scene with a transition
-(void) popSceneWithTransition: (Class)transitionClass duration:(ccTime)t;
{
    NSAssert( _runningScene != nil, @"A running Scene is needed");
    
    [_scenesStack removeLastObject];
    NSUInteger c = [_scenesStack count];
    if( c == 0 ) {
        [self end];
    } else {
        CCScene* scene = [transitionClass transitionWithDuration:t scene:[_scenesStack objectAtIndex:c-1]];
        [_scenesStack replaceObjectAtIndex:c-1 withObject:scene];
        _nextScene = scene;
    }
}

@end
