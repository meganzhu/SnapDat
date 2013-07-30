//
//  GuessLayer.m
//  pics game
//
//  Created by Megan Zhu on 1/8/13.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//  made from brian chu's ghost template
/*  NTS:
 to do:
 trans from gamelayer or photolayer
 randomly choose 3 prompts from wordbank
 display 3 prompts as menu
 take chosen from menu, put into gamedata and moves
 push notif
 goodjob
 */

#import "PromptLayer.h"
#import "CCDirector+PopTransition.h"
#import "CCControlButton.h"
#import "Data.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#include <stdlib.h>
#define numChoices 3

@implementation PromptLayer

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
    
    
    data.inPrompt = YES;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"wordbank" ofType:@"plist"];
    NSDictionary* root = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableArray* wordbank = [NSMutableArray arrayWithArray:[root objectForKey:@"words"]];
    choices = [NSMutableArray array];
    for (int i = 0; i< numChoices; i++){
        double randy = arc4random() % wordbank.count;
        [choices addObject: [wordbank objectAtIndex:(int)randy]];
        [wordbank removeObjectAtIndex:(int)randy];
    }
    //choices is now filled with 3 different words from the wordbank.
    
    //create menu with these 3 words
    CCLabelTTF *title1 = [CCLabelTTF labelWithString:@"Choose a word" fontName:@"Nexa Bold" fontSize:30.0f];

    CCLabelTTF *title2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"for %@", data.opponentName] fontName:@"Nexa Bold" fontSize:30.0f];

    CCControlButton* word1 = [self standardButtonWithTitle:(NSString*)choices[0] font:@"Nexa Bold" fontSize:25 target:self selector:@selector(selected1) preferredSize:CGSizeMake(200, 70)];
    CCControlButton* word2 = [self standardButtonWithTitle:(NSString*)choices[1] font:@"Nexa Bold" fontSize:25 target:self selector:@selector(selected2) preferredSize:CGSizeMake(200, 70)];
    CCControlButton* word3 = [self standardButtonWithTitle:(NSString*)choices[2] font:@"Nexa Bold" fontSize:25 target:self selector:@selector(selected3) preferredSize:CGSizeMake(200, 70)];
    
    title1.position = ccp(160, 400);
    title2.position = ccp(160, 370);
    word1.position = ccp(160, 280);
    word2.position = ccp(160, 220);
    word3.position = ccp(160, 160);
    
    
    [self addChild: title1];
    [self addChild: title2];
    [self addChild: word1];
    [self addChild: word2];
    [self addChild: word3];
    
    return self;
}

-(void) selected1
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    NSString *word = choices[0];
    [super.gameLayer updateGameWithWord: word];
}
-(void) selected2
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    NSString *word = choices[1];
    [super.gameLayer updateGameWithWord: word];
}
-(void) selected3
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    NSString* word = choices[2];
    [super.gameLayer updateGameWithWord: word];
}



-(void) back
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popBack.wav"];
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionSlideInL class] duration:0.25f];
}

@end