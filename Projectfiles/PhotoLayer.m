//
//  PhotoLayer.m
//  pic3
//
//  Created by Megan Zhu on 7/10/13.
//
//

#import "PhotoLayer.h"

@implementation PhotoLayer
-(CCScene*) sceneWithSelf
{
    CCScene* scene = [[self superclass] scene];
    [scene addChild: self];
    return scene;
}

@end
