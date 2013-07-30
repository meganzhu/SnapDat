//
//  GameLayer.m
//  pics game
//
//  Created by Megan Zhu
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//  Using Brian Chu's Ghost template
/*
    NTS: 
    known issues:
    -only loads first game; rest of games just reload first game.
        -data.game only assigned to first game
            -soln: reassign data.game every time you choose a diff player.
    to do:
    -display opponent's prompt & image. 
 */



#import "GameLayer.h"
#import "InterfaceLayer.h"
#import "Lexicontext.h"
#import "CCControlExtension.h"
#import "AppDelegate.h"
#import "CCDirector+PopTransition.h"
#import "ChatLayer.h"
#import "DefinitionViewController.h"
#import "Data.h"
#import "PhotoLayer.h"
#import "HistoryLayer.h"
#import "SimpleAudioEngine.h"

@implementation GameLayer

//return a scene with the layer added to it
-(CCScene*) sceneWithSelf //called after game (layer) is set up
{
    CCScene* scene = [[self superclass] scene];
    [scene addChild: self];
    return scene;
}

-(id) init 
{
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"popForward.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"popBack.wav"];
    self = [super init];
    data = [Data sharedData];
    inChat = NO;
    inGuess = NO;

    return self;
}

-(void) onEnter//happens automatically when we setup game?
{
    if (inChat)
    {
        //Only reload the game if returning from chat view (since getMyInfo preloads all the games), and set chat label text to nothing since there are no unread chats
		chatLabel.string=@"";
		if ([[data.game objectForKey:@"turn"] isEqualToString:data.opponent])
			[MGWU getGame:[[data.game objectForKey:@"gameid"] intValue] withCallback:@selector(gotGame:) onTarget:self];
		inChat = NO;
    }
    if (inGuess)
    {
		inGuess = NO;
	}
    [super onEnter];
}

-(void) setupGame //player & invite table layer brings us here first.
{
    CGSize screenSize = CCDirector.sharedDirector.winSize;
    
    //Top menu bar
    NSString* title = @"Games";
    if (data.game && [data.game objectForKey:@"turn"] != data.username)
    {
        title = @"Waiting..";
    }
    [self addNavBarWithTitle: title];
    [self addBackButton];
    
    //Chat button
    CCMenuItemImage* chat = [CCMenuItemImage itemWithNormalImage:@"chatButton.png" selectedImage:nil target:self selector:@selector(chat)];
    chat.anchorPoint=ccp(1.0,0.5);
    chat.position = ccp(CCDirector.sharedDirector.winSize.width, 27);
    
    //Chat label (number inside chat icon)
    NSString* chatString;
    NSMutableDictionary* game = data.game;
    if (game && [game objectForKey:@"newmessages"] && [[game objectForKey:@"newmessages"] intValue] > 0)
		chatString = [NSString stringWithFormat:@"%@", [game objectForKey:@"newmessages"]];
	else
		chatString = @"";
    chatLabel = [CCLabelTTF labelWithString:chatString fontName:@"Nexa Bold" fontSize:12];
    chatLabel.position = ccp(chat.contentSize.width/2.0 + 1, chat.contentSize.height/2.0); //+1 is because chat icon is not symmetric
    [chat addChild:chatLabel];
    [titleBarMenu addChild:chat z:1];
    
    //node to add everything to in order to center everything
    CCNode* centeringNode = [CCNode node];
    centeringNode.position = ccp(screenSize.width/2.0, (screenSize.height - titleBar.contentSize.height)/2.0);
    
    
    int screenHeight = CCDirector.sharedDirector.winSize.height;
    screenHeight -= titleBar.contentSize.height;
    

    //Add buttons:
    play = [self standardButtonWithTitle:@"PLAY" font:@"Nexa Bold" fontSize:40 target:self selector:@selector(play) preferredSize:CGSizeMake(300, 61)];
    re = [self standardButtonWithTitle:@"REFRESH" font:@"Nexa Bold" fontSize:30 target:self selector:@selector(refresh) preferredSize:CGSizeMake(300, 61)];
    moreGames = [self standardButtonWithTitle:@"MORE GAMES" font:@"Nexa Bold" fontSize:20 target:self selector:@selector(moreGames:) preferredSize:CGSizeMake(173, 57)];
    history = [self standardButtonWithTitle:@"HISTORY" font:@"Nexa Bold" fontSize:30 target:self selector:@selector(history) preferredSize:CGSizeMake(300, 61)];
    
    play.position = ccp(160,92);
	re.position = ccp(160,30);
	moreGames.position = ccp(160,400);
    history.position = ccp(160, 350);
    
    play.position = ccp(play.position.x, screenHeight -play.position.y);
	re.position = ccp(re.position.x, screenHeight - re.position.y);
	moreGames.position = ccp(moreGames.position.x, screenHeight - moreGames.position.y);
    history.position = ccp(history.position.x, screenHeight - history.position.y);

    
    [self addChild:play];
    [self addChild:re];
    [self addChild:moreGames];
    [self addChild:history];
    
    [self loadGame];
    
}

- (void)gotGame:(NSMutableDictionary*)g
{
	//Update game object and reload game
	NSString *gameID = [NSString stringWithFormat:@"%@",[g objectForKey:@"gameid"]];
	
	//Prevent cheating by not reloading game if you challenged but haven't started the next round (since the server doesn't know about the challenge yet)
	NSMutableDictionary *savedGame = [NSMutableDictionary dictionaryWithDictionary:[MGWU objectForKey:gameID]];
	if ([savedGame isEqualToDictionary:@{}])
	{
		data.game = g;
		//If you're friends with the player, add friendName to the game dictionary
		if (data.friendFullName)
			[data.game setObject:data.friendFullName forKey:@"friendName"];
    }
	else
	{
		[data.game setObject:[g objectForKey:@"newmessages"] forKey:@"newmessages"];
	}
	
    if (data.inPrompt){
        //pop prompt scene to show gameLayer
        [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionSlideInR class] duration:0.25f];
        data.inPrompt = NO;
    }
	//Update view
	[self loadGame];
}
            
-(void) loadGame
{
    if (!data.game) //if no game exists yet
    {
        data.new = YES;
        data.promptForMe = @"";
        data.promptForThem = @"";
        data.myPic = nil;
        data.theirPic = nil;
        [play setTitle:@"BEGIN GAME" forState: CCControlStateNormal];
        play.visible = YES;
        re.visible = NO;
        moreGames.visible = NO;
        history.visible = NO;
    }
    else //game exists already (either my turn, or just finished my turn.)
    {
        data.new = NO;
//        NSString* gameState = [data.game objectForKey:@"gamestate"]; no need bc games are never finished ;P
        NSString* turn = [data.game objectForKey: @"turn"];
        NSArray* players = [data.game objectForKey:@"players"];
        data.username = [user objectForKey: @"username"];
		if ([[players objectAtIndex:0] isEqualToString:data.username])
			data.opponent = [players objectAtIndex:1];
		else
			data.opponent = [players objectAtIndex:0];
		
		if ([[data.game allKeys] containsObject:@"friendName"])
		{
			data.friendFullName = [data.game objectForKey:@"friendName"];
			data.opponentName = [InterfaceLayer shortName:data.friendFullName];
			data.playerName = [InterfaceLayer shortName:[user objectForKey:@"name"]];
		}
		else
		{
			data.opponentName = [data.opponent stringByReplacingOccurrencesOfString:@"_" withString:@"."];
			data.playerName = [[user objectForKey:@"username"] stringByReplacingOccurrencesOfString:@"_" withString:@"."];
		}

        if ([turn isEqualToString: data.username]) //if start of my turn, show what friend did
        {                    
            NSDictionary* gameData = [data.game objectForKey: @"gamedata"];
            
            if ([gameData objectForKey:@"theirPic"])
            {
            //show theirPic
            UIImage* theirPic = [gameData objectForKey: @"theirPic"];
            CCSprite* pic = [[CCSprite alloc] initWithCGImage: [theirPic CGImage] key:@"pic"];
            pic.scale = 0.5f;
            pic.position = ccp(160, 240);
            [self addChild: pic];
            }
            //show theirPrompt
            NSString* word = [gameData objectForKey:@"theirPrompt"];
            CCLabelTTF* theirPrompt = [CCLabelTTF labelWithString:word fontName:@"Nexa Bold" fontSize:12];
            theirPrompt.position = ccp(160, 380);
            [self addChild: theirPrompt];
            
            play.position = ccp(160, 70);
            [play setTitle:@"YOUR TURN!" forState: CCControlStateNormal];
            re.visible = NO;
            moreGames.visible = NO;
            play.visible = YES;
            history.visible = YES;
        }
        else //finished my turn, awaiting response.
        {
            NSDictionary* gamedata = [data.game objectForKey: @"gamedata"];
            
            if ([gamedata objectForKey:@"theirPrompt"] && [gamedata objectForKey: @"theirPic"])
            {
                //display their prompt for you
                NSString* word = [gamedata objectForKey: @"theirPrompt"];
                CCLabelTTF* promptForMe = [CCLabelTTF labelWithString:word fontName:@"Nexa Bold" fontSize:12];
                promptForMe.position = ccp (160, 120);
                [self addChild: promptForMe];
                //display my pic that I just took
                UIImage* myPic = [gamedata objectForKey:@"theirPic"];
                CCSprite* pic = [[CCSprite alloc] initWithCGImage:[myPic CGImage] key:@"pic"];
                pic.scale = 0.5f;
                pic.position = ccp(160, 200);
                
            }
            
            
            re.visible = YES;
            moreGames.visible = YES;
            play.visible = NO;
            history.visible = YES;
        }


    }
}


-(void) back
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popBack.wav"];
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionSlideInL class] duration:0.25f];
}

//Go to chat layer
-(void) chat
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    ChatLayer* chatLayer = [[ChatLayer alloc] initWithFriendID:data.opponent];
    inChat = YES;
    
    //slide in from the right
    CCTransitionSlideInR* transition = [CCTransitionSlideInR transitionWithDuration:0.25f scene:[chatLayer sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

- (void)moreGames:(id)sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
	[MGWU displayCrossPromo];
}


-(void) refresh
{
    //If game object exists, reload the game
	if (data.game)
	{
        [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
		[MGWU getGame:[[data.game objectForKey:@"gameid"] intValue] withCallback:@selector(gotGame:) onTarget:self];
	}
}



-(void) play //go to promptlayer or photolayer.
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"start.wav"];
    StyledCCLayer *destination;
    if (data.game) //if theres a game going on, time to take pic. QUESTION:if opponent just played, but this player just oppened app, data.game = nil, right? but there is a game????
    {
        //page flip/swivel transition
        destination = [[PhotoLayer alloc] init];
    }
    else //game just starting; start with prompt.
    {
        destination = [[PromptLayer alloc] init];
        destination.gameLayer = self;
    }
    CCTransitionFlipX* transition = [CCTransitionFlipX transitionWithDuration:0.5f scene:[destination sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

-(void) history //go view history
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    HistoryLayer* historyLayer = [[HistoryLayer alloc] init];
    CCTransitionFlipX* transition = [CCTransitionFlipX transitionWithDuration:0.5f scene:[historyLayer sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

-(void) updateGameWithWord: (NSString*) word
{
//    //clear screen of menu & title
//    [self removeAllChildren];
//    
//    //display word chosen
//    CGSize winSize = [[CCDirector sharedDirector] winSize];
//    
//    CCLabelTTF* youChose = [CCLabelTTF labelWithString:@"You chose" fontName: @"Nexa Bold" fontSize: 30];
//    CCLabelTTF* choice = [CCLabelTTF labelWithString:word fontName: @"Nexa Bold" fontSize: 45];
//    
//    youChose.position = ccp(winSize.width/2, winSize.height/2+20);
//    choice.position = ccp(winSize.width/2, winSize.height/2-20);
//    
//    [self addChild:youChose];
//    [self addChild:choice];
    
    
    //send over word and pic/word set in gamedata
    
    NSMutableDictionary* move;
    int moveNumber;
    NSString* gameState;
    NSMutableDictionary* gameData;
    NSString* opponent = data.opponent;
    NSString* pushMessage;
    NSNumber* gameid;
    if (data.new){
        NSString* player = data.username;
        move = [NSMutableDictionary dictionaryWithDictionary:
                @{@"player" : data.username,}];
        //        @"prompt" : @""}];
        //                 @"pic"    : nil};
        moveNumber = 1;
        gameState = @"started";
        gameData = [NSMutableDictionary dictionaryWithDictionary:@{//@"theirPic"   : nil,
                    @"theirPrompt": @"",
                    @"promptForMe": data.promptForThem}]; //Keys in terms of next person for convenience
        pushMessage = [NSString stringWithFormat:@"%@ challenges you to a game!", data.playerName];
        gameid = @0;
        [MGWU logEvent: @"began_game" withParams: @{@"word":word}];
    }
    else
    {
        move = [NSMutableDictionary dictionaryWithDictionary:@{
                @"player" : data.username,
                @"prompt" : data.promptForMe,
                @"pic"    : data.myPic}];
        moveNumber = [[data.game objectForKey: @"moveCount"] intValue] + 1;
        gameState = @"inprogress";
        gameData = [NSMutableDictionary dictionaryWithDictionary:
                    @{@"theirPic"    : data.myPic,
                    @"theirPrompt" : data.promptForMe,
                    @"promptForMe" : data.promptForThem}];
        gameid = [data.game objectForKey:@"gameid"];
        pushMessage = [NSString stringWithFormat:@"%@ took a picture of something %@ for you!", data.playerName, data.promptForMe];
        
    }
    [MGWU move:move withMoveNumber:moveNumber forGame:gameid withGameState:gameState withGameData:gameData againstPlayer:opponent withPushNotificationMessage:pushMessage withCallback:@selector(gotGame:) onTarget:self];
    
}



@end
