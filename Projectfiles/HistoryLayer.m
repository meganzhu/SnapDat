//
//  HistoryLayer.m
//  pic3
//
//  Created by user on 7/17/13.
//
//

#import "HistoryLayer.h"
#import "CGPointExtension.h"
#import "CCDirector+PopTransition.h"
#import "SimpleAudioEngine.h"
#import "GameLayer.h"

@implementation HistoryLayer

-(CCScene*) sceneWithSelf
{
    CCScene* scene = [[self superclass] scene];
    [scene addChild: self];
    return scene;
}

-(id) init
{
    if(self = [super init])
    {
        data = [Data sharedData];
        prompts = [NSMutableArray arrayWithArray:[[data.game objectForKey: @"gamedata"] objectForKey: @"history"]];
        [self addNavBarWithTitle: @"History"];
        [self addBackButton];
        locy = 85;
        locx = 160;
        moveNumber = [[data.game objectForKey:@"movecount"] intValue];
        for (int i = [prompts count] -1; i >=0; i--, moveNumber--)
        {
            [MGWU getFileWithExtension:@"jpg" forGame:[[data.game objectForKey:@"gameid"] intValue] andMove:moveNumber withCallback:@selector(displayWithPicPath:) onTarget:self];
            locy += 130;
        }
    }
    return self;
}


-(void) displayWithPicPath: (NSString*) picPath
{
    //deal with pic
    Photo* pic = [[Photo alloc] initWithPath:picPath andPos:ccp(locx + 100, locy) andScale: 0.25f];
    [self addChild: pic z:10];
    
    
    //deal with word
    NSString* moveWord = [prompts lastObject];
    CCLabelTTF* word = [CCLabelTTF labelWithString:moveWord fontName:@"Nexa Bold" fontSize:20];
    word.position = ccp(locx-50, locy);
    [self addChild: word];
    [prompts removeLastObject];
}

-(void) back
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popBack.wav"];
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionFlipX class] duration:0.5f];
}

@end
