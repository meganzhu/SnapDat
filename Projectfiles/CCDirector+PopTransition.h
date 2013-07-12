//
//  CCDirector+PopTransition.h
//  Ghost
//
//  Created by Brian Chu on 1/9/13.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "CCDirector.h"

@interface CCDirector (PopTransition)

- (void) popSceneWithTransition: (Class)c duration:(ccTime)t;

@end
