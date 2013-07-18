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
    title1.position = ccp(160, 400);
    CCLabelTTF *title2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"for %@", data.opponentName] fontName:@"Nexa Bold" fontSize:30.0f];
    title2.position = ccp(160, 370);
    CCMenuItem* word1 = [CCMenuItemFont itemWithString:(NSString*)choices[0] target:self selector:@selector(selected1)];
    CCMenuItem* word2 = [CCMenuItemFont itemWithString:(NSString*)choices[1] target:self selector:@selector(selected2)];
    CCMenuItem* word3 = [CCMenuItemFont itemWithString:(NSString*)choices[2] target:self selector:@selector(selected3)];
    CCMenu *menu = [CCMenu menuWithItems: word1, word2, word3, nil];
    menu.position = ccp(160, 200);
    [menu alignItemsVerticallyWithPadding:20.0f];
    [self addChild: title1];
    [self addChild: title2];
    [self addChild: menu];
    
    return self;
}

-(void) selected1
{
    NSString *word = choices[0];
    [super.gameLayer updateGameWithWord: word];
}
-(void) selected2
{
    NSString *word = choices[1];
    [super.gameLayer updateGameWithWord: word];
}
-(void) selected3
{
    NSString* word = choices[2];
    [super.gameLayer updateGameWithWord: word];
}



-(void) back
{
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionSlideInL class] duration:0.25f];
}

@end