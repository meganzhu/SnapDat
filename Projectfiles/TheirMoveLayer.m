//
//  TheirMoveLayer.m
//  pic3
//
//  Created by user on 8/15/13.
//
//

#import "TheirMoveLayer.h"
#import "GameLayer.h"
#import "Data.h"
#import "CCControlExtension.h"
#import "GuessLayer.h"
#import "SimpleAudioEngine.h"
#include <stdlib.h>


@implementation TheirMoveLayer

//return a scene with the layer added to it
-(CCScene*) sceneWithSelf
{
    CCScene* scene = [[self superclass] scene];
    [scene addChild: self];
    return scene;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"popForward.wav"];
        //displayPic
        picx = 160;
        picy = 250;
        if ([GameLayer isIPhone5]) picy = 330;
        picScale = 0.7f;
        data = [Data sharedData];
        
        [MGWU getFileWithExtension: @"jpg" forGame: [[data.game objectForKey:@"gameid"] intValue] andMove: [[data.game objectForKey: @"movecount"] intValue] withCallback:@selector(displayPic:) onTarget:self];
        
        
        CCLabelTTF* friendSent = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@ sent", data.opponentName] fontName:@"Nexa Bold" fontSize:20];
        next = [self standardButtonWithTitle:@"GUESS" font:@"Nexa Bold" fontSize:40 target:self selector:@selector(toGuessLayer) preferredSize:CGSizeMake(300, 61)];
        
        friendSent.position = ccp(160, 440);
        next.position = ccp(160, 50);
        if ([GameLayer isIPhone5]) friendSent.position = ccp(160, 520);

        
        [self addChild: friendSent];
        [self addChild: next];
    }
    return self;
}

-(void) displayPic: (NSString*) path
{
    theirPhoto = [[Photo alloc] initWithPath:path andPos:ccp(picx, picy) andScale:picScale];
    [self addChild: theirPhoto];
}

-(void) toGuessLayer
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];

    StyledCCLayer *guessLayer = [[GuessLayer alloc] init];
    guessLayer.gameLayer = super.gameLayer;
    CCTransitionFlipX* transition = [CCTransitionFlipX transitionWithDuration:0.5f scene:[guessLayer sceneWithSelf]];
    [CCDirector.sharedDirector popScene];
    [CCDirector.sharedDirector pushScene:transition];
}
@end
