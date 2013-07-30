//
//  InterfaceLayer.m
//  Ghost
//
//  Created by Brian Chu on 10/29/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "InterfaceLayer.h"
#import "CCControlExtension.h"
#import "StartLayer.h"
#import "GamesTableLayer.h"
#import "GameLayer.h"
#import "PlayersTableLayer.h"
#import "InviteTableLayer.h"
#import "BadgedCCMenuItemSprite.h"
#import "AppDelegate.h"
#import "CCMenuNoSwallow.h"
#import "SimpleAudioEngine.h"

@interface InterfaceLayer ()
@end

@implementation InterfaceLayer
@synthesize tabBarHeight;
@synthesize currentTableLayer, games,gamesYourTurn, gamesTheirTurn, gamesCompleted;
@synthesize players, nonPlayers, recommendedFriends, newFriends, gamesTab, playersTab, inviteTab;

static InterfaceLayer* sharedInstance; //allows access to interface layer from any other layer

+(id) scene
{
    CCScene *scene = [super scene];
    
    //Add GamesTableLayer
    GamesTableLayer* gamesTableLayer = [[GamesTableLayer alloc] init];
    [scene addChild: gamesTableLayer z:0];
    
    //overlay InterfaceLayer on top of the GamesTableLayer
    //GamesTableLayer is then switched out depending on the table we want
    InterfaceLayer* interfaceLayer = [[InterfaceLayer alloc] initWithTableLayer:gamesTableLayer];
	[scene addChild: interfaceLayer z:1];
	return scene;
}

+(InterfaceLayer*) sharedInstance
{
    return sharedInstance;
}

-(id) initWithTableLayer: (TableLayer*) firstTableLayer
{
	if ((self = [super init]))
	{
        CCDirector* director = CCDirector.sharedDirector;
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"popForward.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"popBack.wav"];
        sharedInstance = self;
        
        //Top menu bar (methods are implemented in StyledCCLayer)
        [self addNavBarWithTitle:@"GAMES"];
        [self addBackButton];

        CCMenuItemImage* refresh = [CCMenuItemImage itemWithNormalImage:@"RefreshButton.png" selectedImage:nil disabledImage:nil target:self selector:@selector(refresh)];
        refresh.anchorPoint=ccp(1.0,0.5);
        refresh.position = ccp(director.winSize.width - 5, titleBar.position.y);
        [titleBarMenu addChild:refresh];

        //Tab bar (at bottom)
        CCSprite* tabBackground = [CCSprite spriteWithFile:@"TabBar.png"];
        tabBackground.anchorPoint=ccp(0,0);
        [self addChild:tabBackground];
        
        CCSprite* gamesSelected = [CCSprite spriteWithFile:@"TabBarSelected.png"];
        CCSprite* gamesSelectedIcon = [CCSprite spriteWithFile:@"GhostIconSelected.png"];
        gamesSelectedIcon.position = ccpMult(ccpFromSize(gamesSelected.contentSize), 0.5);
        [gamesSelected addChild:gamesSelectedIcon];
        gamesSelected.position = ccpAdd(gamesSelected.position, ccp(4,-5)); //hack to get everything to line up
        gamesTab = [BadgedCCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"GhostIcon.png"] selectedSprite:gamesSelected target:self selector:@selector(gamesClick)];

        CCSprite* playersSelected = [CCSprite spriteWithFile:@"TabBarSelected.png"];
        CCSprite* playersSelectedIcon = [CCSprite spriteWithFile:@"PlusIconSelected.png"];
        playersSelectedIcon.position = ccpMult(ccpFromSize(playersSelected.contentSize), 0.5);
        [playersSelected addChild:playersSelectedIcon];
        playersSelected.position = ccpAdd(playersSelected.position, ccp(4,-5)); //hack to get everything to line up
        playersTab = [BadgedCCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"PlusIcon.png"] selectedSprite:playersSelected target:self selector:@selector(playersClick)];
        
        CCSprite* inviteSelected = [CCSprite spriteWithFile:@"TabBarSelected.png"];
        CCSprite* inviteSelectedIcon = [CCSprite spriteWithFile:@"PersonIconSelected.png"];
        inviteSelectedIcon.position = ccpMult(ccpFromSize(inviteSelected.contentSize), 0.5);
        [inviteSelected addChild:inviteSelectedIcon];
        inviteSelected.position = ccpAdd(inviteSelected.position, ccp(4,-5)); //hack to get everything to line up
        inviteTab =[BadgedCCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"PersonIcon.png"] selectedSprite:inviteSelected target:self selector:@selector(inviteClick)];

        gamesTab.isEnabled=NO; //since we start out at the GamesTable layer, we di	sable the ability to click the Games tab
        disabledItem=gamesTab;
        
        CCMenuNoSwallow* tabMenu = [CCMenuNoSwallow menuWithItems:gamesTab, playersTab, inviteTab, nil];
        [tabMenu alignItemsHorizontallyWithPadding:0];
        tabMenu.anchorPoint=ccp(0.5,0.5);
        tabMenu.position = ccp(CCDirector.sharedDirector.winSize.width/2.0, tabBackground.contentSize.height/2.0);

        [tabBackground addChild:tabMenu];
        
        
        //properly initialize tableLayer
        gamesTableLayer=(GamesTableLayer*) firstTableLayer;
        tabBarHeight = tabBackground.contentSize.height;
        [self setupTableLayer:firstTableLayer];
	}
	return self;
}

//sets up the table layer we're loading in next
-(void) setupTableLayer: (TableLayer*) newTableLayer;
{
    currentTableLayer=newTableLayer;
    [newTableLayer setupWithTabBarHeight:tabBarHeight titleBarHeight:titleBar.contentSize.height];
}

//called when back arrow is pressed in nav bar
-(void) back
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popBack.wav"];
    //slide in scene from the left
    CCTransitionSlideInR* transition = [CCTransitionSlideInL transitionWithDuration:0.25f scene:[StartLayer scene]];
    [CCDirector.sharedDirector replaceScene:transition];
}

-(void) refresh
{
    [MGWU getMyInfoWithCallback:@selector(loadedUserInfo:) onTarget:self];
}

//Take user to update screen if he taps download update (see first bit of code in loadedUserInfo method)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == updateAlertView)
	{
		if (updateAlertView.numberOfButtons == 1 || buttonIndex == 1)
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateURL]];
		else
			[updateAlertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
		updateAlertView = nil;
	}
}

- (void)loadedUserInfo:(NSMutableDictionary*)userInfo
{
    //THIS CODE IS COMMENTED OUT FOR THE TEMPLATE
	//You likely want to use this when your app is ready for the app store
	//Checks whether the server has any info about a new version, prompts user to update, or forces user to update depending on response from server
//	if ([[userInfo allKeys] containsObject:@"appversion"])
//	{
//		updateURL = [userInfo objectForKey:@"updateurl"];
//		NSString *latestVersion = [userInfo objectForKey:@"appversion"];
//		NSString *curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
//		if ([curVersion compare:latestVersion options:NSNumericSearch] == NSOrderedAscending)
//		{
//			if (!updateAlertView)
//			{
//				if ([[userInfo allKeys] containsObject:@"forceupdate"])
//					updateAlertView = [[UIAlertView alloc] initWithTitle:@"Update Required" message:@"You must download the latest update to continue playing" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Download Now!", nil];
//				else
//					updateAlertView = [[UIAlertView alloc] initWithTitle:@"Update Available" message:@"A new update has been released on the app store" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Download Now!", nil];
//				[updateAlertView show];
//			}
//		}
//	}
    
	user = [userInfo objectForKey:@"info"];
	games = [userInfo objectForKey:@"games"];
	players = [userInfo objectForKey:@"friends"];
	nonPlayers = [MGWU friendsToInvite];
    Data* data = [Data sharedData];
    data.username = [user objectForKey: @"username"];
	
	NSArray *playingFriends = [NSArray arrayWithArray:players];
	
	if (currentTableLayer!=playersTableLayer)
	{
		//Set badge number for new friends when they join the game
		int numOldFriends = [[NSUserDefaults standardUserDefaults] integerForKey:@"numFriends"];
		int numNewFriends = [players count];
		if (numNewFriends > numOldFriends)
		{
			newFriends = numNewFriends-numOldFriends;
		}
	}
	
	//Some open graph magic
	if (counter%3 == 0)
	{
		NSMutableArray *followedFriends = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"og_followed"]];
		NSMutableArray *ogPlayingFriends = [[NSMutableArray alloc] init];
		for (NSMutableDictionary *p in players)
		{
			[ogPlayingFriends addObject:[p objectForKey:@"username"]];
		}
		NSPredicate *relativeComplementPredicate = [NSPredicate predicateWithFormat:@"NOT SELF IN %@", followedFriends];
		NSArray *relativeComplement = [ogPlayingFriends filteredArrayUsingPredicate:relativeComplementPredicate];
		if ([relativeComplement count] > 0)
		{
			int r = arc4random()%[relativeComplement count];
			NSString *usernameToFollow = [relativeComplement objectAtIndex:r];
			[followedFriends addObject:usernameToFollow];
			[[NSUserDefaults standardUserDefaults] setObject:followedFriends forKey:@"og_followed"];
			//Publish Open Graph
			NSString *opid = [MGWU fbidFromUsername:usernameToFollow];
			[MGWU publishOpenGraphAction:@"follow" withParams:@{@"profile":opid}];
		}
	}
	counter++;
	
	
	//Sort games by dateplayed
	NSArray *sortedGames = [games sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
		NSNumber *first = [a objectForKey:@"dateplayed"];
		NSNumber *second = [b objectForKey:@"dateplayed"];
		return [second compare:first];
	}];
	
	games = [NSMutableArray arrayWithArray:sortedGames];
	
	
	//Split up games based on whose turn it is / whether the game is over
    gamesCompleted = [[NSMutableArray alloc] init];
    gamesYourTurn = [[NSMutableArray alloc] init];
    gamesTheirTurn = [[NSMutableArray alloc] init];
	
	NSString *username = [user objectForKey:@"username"];
	
	for (NSMutableDictionary *game in games)
	{
		NSString* gameState = [game objectForKey:@"gamestate"];
		NSString* turn = [game objectForKey:@"turn"];
		
		NSString* oppName;
		NSArray* gamers = [game objectForKey:@"players"];
		if ([[gamers objectAtIndex:0] isEqualToString:username])
			oppName = [gamers objectAtIndex:1];
		else
			oppName = [gamers objectAtIndex:0];
        
		if ([gameState isEqualToString:@"ended"])
		{
			[gamesCompleted addObject:game];
			for (NSMutableDictionary *friend in players)
			{
				//Add friendName to game if you're friends
				if ([[friend objectForKey:@"username"] isEqualToString:oppName])
				{
					[game setObject:[friend objectForKey:@"name"] forKey:@"friendName"];
					break;
				}
			}
		}
		else if ([turn isEqualToString:[user objectForKey:@"username"]])
		{
			//Preventing cheating
			NSString *gameID = [NSString stringWithFormat:@"%@",[game objectForKey:@"gameid"]];
			NSMutableDictionary *savedGame = [NSMutableDictionary dictionaryWithDictionary:[MGWU objectForKey:gameID]];
			if ([savedGame isEqualToDictionary:@{}])
				savedGame = game;
			else
				[savedGame setObject:[game objectForKey:@"newmessages"] forKey:@"newmessages"];
			[gamesYourTurn addObject:savedGame];
			for (NSMutableDictionary *friend in playingFriends)
			{
				//Add friendName to game if you're friends, remove the friend from list of players (so you can't start a new game with someone you're already playing)
				if ([[friend objectForKey:@"username"] isEqualToString:oppName])
				{
					[savedGame setObject:[friend objectForKey:@"name"] forKey:@"friendName"];
					[players removeObject:friend];
					break;
				}
			}
		}
		else
		{
			[gamesTheirTurn addObject:game];
			for (NSMutableDictionary *friend in playingFriends)
			{
				//Add friendName to game if you're friends, remove the friend from list of players (so you can't start a new game with someone you're already playing)
				if ([[friend objectForKey:@"username"] isEqualToString:oppName])
				{
					[game setObject:[friend objectForKey:@"name"] forKey:@"friendName"];
					[players removeObject:friend];
					break;
				}
			}
		}
	}
	
	//Adding recommended friends:
	recommendedFriends = [[NSMutableArray alloc] init];
	
	NSMutableArray *randomPlayingFriends = [NSMutableArray arrayWithArray:players];
	NSMutableArray *randomNonPlayingFriends = [NSMutableArray arrayWithArray:[MGWU friendsToInvite]];
	
	//Shuffle list of friends who play the game
	if ([randomPlayingFriends count] > 0)
	{
		for (NSUInteger i = [randomPlayingFriends count] - 1; i >= 1; i--)
		{
			u_int32_t j = arc4random_uniform(i + 1);
			
			[randomPlayingFriends exchangeObjectAtIndex:j withObjectAtIndex:i];
		}
	}
	
	//Shuffle list of friends who don't play yet
	if ([randomNonPlayingFriends count] > 0)
	{
		for (NSUInteger i = [randomNonPlayingFriends count] - 1; i >= 1; i--)
		{
			u_int32_t j = arc4random_uniform(i + 1);
			
			[randomNonPlayingFriends exchangeObjectAtIndex:j withObjectAtIndex:i];
		}
	}
	
	NSUInteger i=0;
	
	for (i = 0; i < 2 && i < [randomPlayingFriends count]; i++)
	{
		[recommendedFriends addObject:[randomPlayingFriends objectAtIndex:i]];
	}
	for (int j = i; j < 3 && (j-i < [randomNonPlayingFriends count]); j++)
	{
		[recommendedFriends addObject:[randomNonPlayingFriends objectAtIndex:j-i]];
	}
	
    //Set badges on tab bar based on games that are your turn and new friends who are playing    
    //handle tab button badges
    
	gamesTab.badgeString = [NSString stringWithFormat:@"%d", [gamesYourTurn count]];
	if (newFriends == 0)
		playersTab.badgeString = nil;
	else
		playersTab.badgeString = [NSString stringWithFormat:@"%d", newFriends];
	
	[self refreshAll];

}

//refreshes all tables - InviteTableLayer is left out for performance reasons
-(void) refreshAll
{
    [gamesTableLayer reloadData];
    [playersTableLayer reloadData];
}

//Remove table layer
-(void) tableCleanup;
{
    [currentTableLayer removeFromParentAndCleanup:NO];
    [currentTableLayer pauseSchedulerAndActions];
    currentTableLayer=nil;
    disabledItem.isEnabled = YES; //"unselect" the tab button that is pressed down
}

//Games tab button clicked (first tab)
-(void) gamesClick
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    [self tableCleanup];
    title.string = @"GAMES"; //nav bar title
    
    //if we already have the layer set up (and cached)
    if (gamesTableLayer)
        [gamesTableLayer resumeSchedulerAndActions];
    //otherwise, set up a new layer
    else
    {
        gamesTableLayer=[[GamesTableLayer alloc] init];
        [self setupTableLayer:gamesTableLayer];
    }
    currentTableLayer=gamesTableLayer;
    [CCDirector.sharedDirector.runningScene addChild:currentTableLayer z:0];
    
    //permanently select the tab button to indicate that we are on that tab.
    disabledItem = gamesTab;
    disabledItem.isEnabled=NO;
//    [currentTableLayer refresh];
}

//Players tab button clicked (second tab)
-(void) playersClick
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    [self tableCleanup];
    title.string = @"NEW GAME";
    if (playersTableLayer)
    {
        [playersTableLayer resumeSchedulerAndActions];
    }
    else
    {
        playersTableLayer=[[PlayersTableLayer alloc] init];
        [self setupTableLayer:playersTableLayer];
    }
    currentTableLayer=playersTableLayer;
    [CCDirector.sharedDirector.runningScene addChild:currentTableLayer z:0];
    disabledItem = playersTab;
    disabledItem.isEnabled=NO;
}

//Invite tab button clicked (third tab)
-(void) inviteClick
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    [self tableCleanup];
    title.string = @"INVITE";
    if (inviteTableLayer)
    {
        [inviteTableLayer resumeSchedulerAndActions];
    }
    else
    {
        inviteTableLayer=[[InviteTableLayer alloc] init];
        [self setupTableLayer:inviteTableLayer];
    }
    currentTableLayer=inviteTableLayer;
    [CCDirector.sharedDirector.runningScene addChild:currentTableLayer z:0];
    disabledItem = inviteTab;
    disabledItem.isEnabled=NO;
}

//abbreviates friend names
+ (NSString*)shortName:(NSString*)friendname
{
	NSArray *names = [friendname componentsSeparatedByString:@" "];
	NSString * firstLetter = [[names objectAtIndex:([names count]-1)] substringToIndex:1];
	NSString *shortname;
	if ([names count] > 1)
		shortname = [[names objectAtIndex:0] stringByAppendingFormat:@" %@", firstLetter];
	else
		shortname = [names objectAtIndex:0];
	shortname = [shortname stringByAppendingString:@"."];
	return shortname;
}

//Every time the game returns to any of the 3 tables (from a game), all three get refreshed
-(void) onEnter
{
    [currentTableLayer refresh];
    [super onEnter];
}


@end
