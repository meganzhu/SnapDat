//
//  GameLayer.m
//  pics game
//
//  Created by Megan Zhu
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//  Using Brian Chu's Ghost template



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

@implementation GameLayer

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
    data = [Data sharedData];
    inChat = NO;
    inGuess = NO;
    data.username = [user objectForKey: @"username"];
    return self;
}

-(void) onEnter
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
    [self addNavBarWithTitle:@"Games"];
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
    
    play.position = ccp(160,92);
	re.position = ccp(160,92);
	moreGames.position = ccp(160,282);
    
    play.position = ccp(play.position.x, screenHeight -play.position.y);
	re.position = play.position;
	moreGames.position = ccp(moreGames.position.x, screenHeight - moreGames.position.y);
    
    [self addChild:play];
    [self addChild:re];
    [self addChild:moreGames];
    
    [self loadGame];
    
}

- (void)gotGame:(NSMutableDictionary*)g
{
	//Update game object and reload game
	NSString *gameID = [NSString stringWithFormat:@"%@",[data.game objectForKey:@"gameid"]];
	
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
	
	//Update view
	[self loadGame];
}

-(void) loadGame
{
    NSMutableDictionary* game = data.game;
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
        
    }
    else //game exists already
    {
        data.new = NO;
        NSString* gameState = [data.game objectForKey:@"gamestate"];
        NSString* turn = [data.game objectForKey: @"turn"];
        NSArray* players = [data.game objectForKey:@"players"];
		if ([[players objectAtIndex:0] isEqualToString:[user objectForKey:@"username"]])
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
        //INSERT LATER: show theirPic, theirPrompt (in gamedata)
        
		//go take a pic for their prompt
        CCTransitionFlipX* transition = [CCTransitionFlipX transitionWithDuration:0.5f scene:[[PhotoLayer alloc] sceneWithSelf]];
        [CCDirector.sharedDirector pushScene:transition];
    }
}


-(void) back
{
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionSlideInL class] duration:0.25f];
}

//Go to chat layer
-(void) chat
{
    ChatLayer* chatLayer = [[ChatLayer alloc] initWithFriendID:data.opponent];
    inChat = YES;
    
    //slide in from the right
    CCTransitionSlideInR* transition = [CCTransitionSlideInR transitionWithDuration:0.25f scene:[chatLayer sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

- (void)moreGames:(id)sender
{
	[MGWU displayCrossPromo];
}


-(void) refresh
{
    [MGWU getMyInfoWithCallback:@selector(loadedUserInfo:) onTarget:self];
}

-(void) play //go to guesslayer or photolayer.
{
    StyledCCLayer *destination;
    if (data.game) //if theres a game going on, time to take pic. QUESTION:if opponent just played, but this player just oppened app, data.game = nil, right? but there is a game????
    {
        //page flip/swivel transition
        destination = [[PhotoLayer alloc] init];
    }
    else //game just starting; start with prompt.
    {
        destination = [[PromptLayer alloc] init];
    }
    CCTransitionFlipX* transition = [CCTransitionFlipX transitionWithDuration:0.5f scene:[destination sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}
@end
