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
#import "CCControlButton.h"
#import "Data.h"
#include <stdlib.h>
#define numChoices 3

@implementation PromptLayer
@synthesize choices;

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
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"wordbank" ofType:@"plist"];
    NSMutableArray *wordbank = [NSArray arrayWithContentsOfFile:filePath];
    choices = [NSMutableArray arrayWithCapacity:numChoices];
    for (int i = 0; i < (int)choices.count; i++){
        double randy = rand() % wordbank.count;
        [choices addObject: [wordbank objectAtIndex:randy]];
        [wordbank removeObjectAtIndex:randy];
    }
    //choices is now filled with 3 different words from the wordbank.
    
    //create menu with these 3 words
    
    CCMenuItem* word1 = [CCMenuItemFont itemWithString:(NSString*)choices[1] target:self selector:@selector(selected1:)];
    CCMenuItem* word2 = [CCMenuItemFont itemWithString:(NSString*)choices[2] target:self selector:@selector(selected2:)];
    CCMenuItem* word3 = [CCMenuItemFont itemWithString:(NSString*)choices[3] target:self selector:@selector(selected3:)];
    CCMenu *menu = [CCMenu menuWithItems: word1, word2, word3, nil];
    menu.position = ccp(160, 150);
    [self addChild: menu];
    
    return self;
}

-(void) selected1
{
    NSString *word = choices[1];
    [self updateGameWithWord: word];
}
-(void) selected2
{
    NSString *word = choices[2];
    [self updateGameWithWord: word];
}
-(void) selected3
{
    NSString* word = choices[3];
    [self updateGameWithWord: word];
}

-(void) updateGameWithWord: (NSString*) word
{
    Data* data = [Data sharedData];
    //display word chosen
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCLabelTTF* youChose = [CCLabelTTF labelWithString:@"You chose" fontName: @"Nexa Bold" fontSize: 20];
    CCLabelTTF* choice = [CCLabelTTF labelWithString:word fontName: @"Nexa Bold" fontSize: 40];
    
    youChose.position = ccp(winSize.height/2 + 50, winSize.width/2);
    choice.position = ccp(winSize.height/2 -50, winSize.width/2);
    
    youChose.color = ccc3(255, 255, 255);
    choice.color = ccc3(255, 255, 255);
    
    [self addChild:youChose];
    [self addChild:choice];
    
    
    //send over word and pic/word set in gamedata
    
    NSMutableDictionary* move;
    int moveNumber;
    NSString* gameState;
    NSMutableDictionary* gameData;
    NSString* opponent = data.opponent;
    NSString* pushMessage;
    NSNumber* gameid;
    if (data.new){
        move = @{@"player" : data.username,
                 @"prompt" : @""};
//                 @"pic"    : nil};
        moveNumber = 0;
        gameState = @"Started";
        gameData = @{//@"theirPic"   : nil,
                     @"theirPrompt": @"",
                     @"promptForMe": data.promptForThem}; //Keys in terms of next person for convenience
        pushMessage = [NSString stringWithFormat:@"%@ challenges you to a game!", data.playerName];
        gameid = @0;
        [MGWU logEvent: @"began_game" withParams: @{@"word":word}];
    }
    else
    {
        move = @{@"player" : data.username,
                 @"prompt" : data.promptForMe,
                 @"pic"    : data.myPic};
        moveNumber = [[data.game objectForKey: @"moveCount"] intValue] + 1;
        gameState = @"inprogress";
        gameData = @{@"theirPic"    : data.myPic,
                     @"theirPrompt" : data.promptForMe,
                     @"promptForMe" : data.promptForThem};
        gameid = [data.game objectForKey:@"gameid"];
        pushMessage = [NSString stringWithFormat:@"%@ took a picture of something %@ for you!", data.playerName, data.promptForMe];
            
    }
    [MGWU move:move withMoveNumber:moveNumber forGame:gameid withGameState:gameState withGameData:gameData againstPlayer:opponent withPushNotificationMessage:pushMessage withCallback:@selector(moveCompleted:) onTarget:self];
    
}

@end