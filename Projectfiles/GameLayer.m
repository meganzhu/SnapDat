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

-(void) setupGame
{
    CGSize screenSize = CCDirector.sharedDirector.winSize;
    [self removeAllChildren];
    
    //Top menu bar
    NSString* title = @"Games";
    if (data.game && ![[data.game objectForKey:@"turn"] isEqualToString: data.username])
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
    end = [self standardButtonWithTitle:@"QQ" font: @"Nexa Bold" fontSize:50 target:self selector:@selector(endGame) preferredSize:CGSizeMake(300, 61)];
    
//    play.position = ccp(160,300); //play loc varies whether beginning game or not.
	re.position = ccp(160,30);
	moreGames.position = ccp(160,400);
    history.position = ccp(160, 350);
    end.position = ccp(160, 300);
    
    //play.position = ccp(play.position.x, screenHeight -play.position.y);
	re.position = ccp(re.position.x, screenHeight - re.position.y);
	moreGames.position = ccp(moreGames.position.x, screenHeight - moreGames.position.y);
    history.position = ccp(history.position.x, screenHeight - history.position.y);
    end.position = ccp(end.position.x, screenHeight - end.position.y);

    
    [self addChild:play];
    [self addChild:re];
    [self addChild:moreGames];
    [self addChild:history];
    [self addChild:end];
    
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
        
        //set all our game variables in data, for ease of access
        data.promptForMe = [[data.game objectForKey: @"gamedata"] objectForKey: @"promptForMe"];
        data.friendFullName = [data.game objectForKey:@"friendName"];
        data.opponentName = [InterfaceLayer shortName:data.friendFullName];
        data.playerName = [InterfaceLayer shortName:[user objectForKey:@"name"]];
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
        data.myPicPath = nil;
        play.position = ccp(160, 330);
        [play setTitle:@"BEGIN GAME" forState: CCControlStateNormal];
        play.visible = YES;
        re.visible = NO;
        moreGames.visible = NO;
        history.visible = NO;
        end.visible = NO;
        displayWord.visible = NO;
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
            data.promptForMe = [[data.game objectForKey: @"gamedata"] objectForKey: @"promptForMe"];
            
            if ([[data.game objectForKey: @"movecount"] intValue] > 1) 
            {
                [MGWU getFileWithExtension: @"jpg" forGame: [[data.game objectForKey:@"gameid"] intValue] andMove: [[data.game objectForKey: @"movecount"] intValue] withCallback:@selector(displayImage:) onTarget:self];
            }
                
            //show theirPrompt
            NSString* word = [gameData objectForKey:@"theirPrompt"];
            if (word)
            {
                [self removeChild: displayWord];
                displayWord = [CCLabelTTF labelWithString:word fontName:@"Nexa Bold" fontSize:20];
                displayWord.position = ccp(160, 380);
                [self addChild: displayWord];
            }
            play.position = ccp(160, 50);
            [play setTitle:@"YOUR TURN!" forState: CCControlStateNormal];
            re.visible = NO;
            moreGames.visible = NO;
            play.visible = YES;
            history.visible = NO;
            end.visible = NO;
        }
        else //finished my turn, awaiting response. Display my pic and the prompt that it was for
        {
            NSDictionary* gamedata = [data.game objectForKey: @"gamedata"];
            
            if ([gamedata objectForKey:@"theirPrompt"])
            {
                //display their prompt for you
                [self removeChild: displayWord];
                NSString* word = [gamedata objectForKey: @"theirPrompt"];
                displayWord = [CCLabelTTF labelWithString:word fontName:@"Nexa Bold" fontSize:20];
                displayWord.position = ccp(160, 360);
                [self addChild: displayWord];
            }
            if ([[data.game objectForKey: @"movecount"] intValue] > 1)
            {
                [MGWU getFileWithExtension: @"jpg" forGame: [[data.game objectForKey:@"gameid"] intValue] andMove: [[data.game objectForKey: @"movecount"] intValue] withCallback:@selector(displayImage:) onTarget:self];
                
            }
            
            re.visible = YES;
            moreGames.visible = YES;
            play.visible = NO;
            history.visible = YES;
            end.visible = NO;
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
    if (!data.new)
    {
        //page flip/swivel transition
        destination = [[PhotoLayer alloc] init];
        destination.gameLayer = self;
    }
    else //game just starting; start with prompt.
    {
        destination = [[PromptLayer alloc] init];
        destination.gameLayer = self;
    }
    CCTransitionFlipX* transition = [CCTransitionFlipX transitionWithDuration:0.5f scene:[destination sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

-(void) endGame
{
    //crytears because i messed up; delete game so we can restart.
    data.new = TRUE;
    //First I'll set data.game to nil
    //Now I'll try to get variables out of a nil object
    //I wonder what could possibly be going wrong?!?!
    [MGWU move:@{} withMoveNumber:([[data.game objectForKey: @"movecount"] intValue] + 1) forGame:[[data.game objectForKey:@"gameid"] intValue] withGameState:@"ended" withGameData:@{} againstPlayer:data.opponent withPushNotificationMessage:@"" withCallback:@selector(gameEndCheck:) onTarget:self];
}

-(void) gameEndCheck: (NSDictionary*) game
{
    NSLog(@"%@", game);// [MGWU getMyInfoWithCallback:@selector(gotUserInfo:) onTarget:self];
}

-(void) gotUserInfo: (NSMutableDictionary*) user
{
    [self setupGame];
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
    //send over word and pic/word set in gamedata
    NSMutableDictionary* move;
    int moveNumber;
    NSString* gameState;
    NSMutableDictionary* gamedata;
    NSString* opponent = data.opponent;
    NSString* pushMessage;
    int gameid;
    if (data.new)
    {
        move = [NSMutableDictionary dictionaryWithDictionary:
                @{@"player" : data.username,}];
        //no prompt or picture.
        moveNumber = 1;
        gameState = @"started";
        gamedata = [NSMutableDictionary dictionaryWithDictionary:@{
                    @"promptForMe": word}]; //Keys in terms of next person for convenience. No prompt or pic
        pushMessage = [NSString stringWithFormat:@"%@ challenges you to a game!", data.playerName];
        gameid = 0;
        [MGWU logEvent: @"began_game" withParams: @{@"word":word}];
    }
    else
    {
        move = [NSMutableDictionary dictionaryWithDictionary:@{
                @"player" : data.username,
                @"prompt" : data.promptForMe,
                @"move-file" : data.myPicPath}];
        moveNumber = [[data.game objectForKey: @"movecount"] intValue] + 1;
        gameState = @"inprogress";
        gamedata = [NSMutableDictionary dictionaryWithDictionary:
                    @{//@"theirPic"    : data.myPic,
                    @"theirPrompt" : data.promptForMe,
                    @"promptForMe" : word}];
        gameid = [[data.game objectForKey:@"gameid"] intValue];
        pushMessage = [NSString stringWithFormat:@"%@ took a picture of something %@ for you!", data.playerName, data.promptForMe];
        
    }
    [MGWU move:move withMoveNumber:moveNumber forGame:gameid withGameState:gameState withGameData:gamedata againstPlayer:opponent withPushNotificationMessage:pushMessage withCallback:@selector(gotGame:) onTarget:self];
    //    [MGWU move:@{} withMoveNumber:([[data.game objectForKey: @"movecount"] intValue] + 1) forGame:[[data.game objectForKey:@"gameid"] intValue] withGameState:@"ended" withGameData:@{} againstPlayer:data.opponent withPushNotificationMessage:@"" withCallback:@selector(gameEndCheck:) onTarget:self];
}

- (void) displayImage: (NSString*) imagePath
{
    UIImage* image = [self loadImageAtPath: imagePath];
    if (!image)
    {
        return;
    }
    [self removeChild: displayPic];
    displayPic = [[CCSprite alloc] initWithCGImage:[image CGImage] key:@"pic"];
    displayPic.scale = 0.5f;
    displayPic.position = ccp(160, 200);
    [self addChild: displayPic];
}
- (UIImage*)loadImageAtPath: (NSString*)path
{
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}


@end
