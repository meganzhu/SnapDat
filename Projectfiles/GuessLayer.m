//
//  GuessLayer.m
//  pic3
//
//  Created by Megan Zhu on 8/6/13.
//
//

#import "GuessLayer.h"
#import "PromptLayer.h"
#import "CCDirector+PopTransition.h"
#import "CCControlButton.h"
#import "Data.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#include <stdlib.h>

@implementation GuessLayer

//return a scene with the layer added to it
-(CCScene*) sceneWithSelf
{
    CCScene* scene = [[self superclass] scene];
    [scene addChild: self];
    return scene;
}

-(id) init
{
    data = [Data sharedData];
    self = [super init];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"popForward.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"popBack.wav"];
    
    //create menu with these 3 words
    prompt = [[data.game objectForKey: @"gamedata"] objectForKey: @"prompt"];
    prompts = [[data.game objectForKey: @"gamedata"] objectForKey: @"prompts"];
    
    CCLabelTTF *title1 = [CCLabelTTF labelWithString:@"What word did" fontName:@"Nexa Bold" fontSize:30.0f];
    CCLabelTTF *title2 = [CCLabelTTF labelWithString:data.opponentName fontName:@"Nexa Bold" fontSize:40.0f];
    CCLabelTTF *title3 = [CCLabelTTF labelWithString:@"take a pic of?" fontName:@"Nexa Bold" fontSize:30.0f];
    
    CCControlButton* word1 = [self standardButtonWithTitle:(NSString*)prompts[0] font:@"Nexa Bold" fontSize:25 target:self selector:@selector(selected1) preferredSize:CGSizeMake(200, 70)];
    CCControlButton* word2 = [self standardButtonWithTitle:(NSString*)prompts[1] font:@"Nexa Bold" fontSize:25 target:self selector:@selector(selected2) preferredSize:CGSizeMake(200, 70)];
    CCControlButton* word3 = [self standardButtonWithTitle:(NSString*)prompts[2] font:@"Nexa Bold" fontSize:25 target:self selector:@selector(selected3) preferredSize:CGSizeMake(200, 70)];
    
    title1.position = ccp(160, 400);
    title2.position = ccp(160, 370);
    title3.position = ccp(160,340);
    word1.position = ccp(160, 280);
    word2.position = ccp(160, 220);
    word3.position = ccp(160, 160);
    
    
    [self addChild: title1];
    [self addChild: title2];
    [self addChild: title3];
    [self addChild: word1];
    [self addChild: word2];
    [self addChild: word3];
    
    return self;
}

-(void) selected1
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    data.guess = prompts[0];
    correct = [data.guess isEqualToString: prompt];
    [self displayResult];
}
-(void) selected2
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    data.guess = prompts[1];
    correct = [data.guess isEqualToString: prompt];
    [self displayResult];
}
-(void) selected3
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    data.guess = prompts[2];
    correct = [data.guess isEqualToString: prompt];
    [self displayResult];
}

-(void) displayResult //POSSIBLE CHANGE: Points?
{
    //log guess!
    [MGWU logEvent: @"guessed" withParams: @{
        @"correct" : [NSNumber numberWithBool:correct],
        @"guess"   : data.guess,
        @"actual"  : prompt}];
    
    [self removeAllChildren];
    CCLabelTTF* result;
    CCLabelTTF* subtitle = [CCLabelTTF labelWithString:@"The word was" fontName:@"Nexa Bold" fontSize:30.0f];
    CCLabelTTF* subsubtitle = [CCLabelTTF labelWithString: prompt fontName: @"Nexa Bold" fontSize:40.0f];
    CCControlButton* next;
    
    if (correct)
    {
        result = [CCLabelTTF labelWithString:@"CORRECT!" fontName:@"Nexa Bold" fontSize:40.0f];
        next = [self standardButtonWithTitle:@"Yippee!" font:@"Nexa Bold" fontSize:25 target:self selector:@selector(toPromptLayer) preferredSize:CGSizeMake(200, 70)];
    }
    else
    {
        result = [CCLabelTTF labelWithString:@"WRONG!" fontName:@"Nexa Bold" fontSize:40.0f];
        next = [self standardButtonWithTitle:@"Baww.." font:@"Nexa Bold" fontSize:25 target:self selector:@selector(toPromptLayer) preferredSize:CGSizeMake(200, 70)];
    }
    result.position = ccp(160, 400);
    subtitle.position = ccp(160, 370);
    subsubtitle.position = ccp(160, 340);
    next.position = ccp(160, 160);
    
    [self addChild: result];
    [self addChild: subtitle];
    [self addChild: subsubtitle];
    [self addChild: next];
}

-(void) toPromptLayer
{
    PromptLayer* promptLayer = [[PromptLayer alloc] init];
    promptLayer.gameLayer = super.gameLayer;
    
    [CCDirector.sharedDirector popScene];
    CCTransitionFlipX* transition = [CCTransitionFlipX transitionWithDuration:0.5f scene:[promptLayer sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

-(void) back
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popBack.wav"];
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionSlideInL class] duration:0.25f];
}

@end
