//
//  PlayersTableLayer.m
//  Ghost
//
//  Created by Brian Chu on 11/15/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "PlayersTableLayer.h"
#import "GameLayer.h"
#import "BadgedCCMenuItemSprite.h"
#import "CCControlButton.h"
#import "AppDelegate.h"
#import "CCMenuNoSwallow.h"
#import "Data.h"
#import "SimpleAudioEngine.h"

#define PLAYERS_SECTIONS 3

@implementation PlayersTableLayer


-(void) setupWithTabBarHeight:(float)tabBarHeightIn titleBarHeight:(float)titleBarHeightIn
{
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"popForward.wav"];
    
    //set up references and properties
    tabBarHeight=tabBarHeightIn;
    interfaceLayer=[InterfaceLayer sharedInstance];
    
    //add an image that is placed on top of the table to hide cells that are at the top of the table
    //18 would be gap between button and top of view (handled by backgroundTopClip)
    [self addBackgroundTopClip];
    backgroundTopClip.position = ccp(backgroundTopClip.position.x, backgroundTopClip.position.y - titleBarHeightIn);
    
    //invite friends button
    CCControlButton* inviteFriend = [self standardButtonWithTitle:@"INVITE FRIENDS" font:@"Nexa Bold" fontSize:18 target:interfaceLayer selector:@selector(inviteClick) preferredSize:CGSizeMake(320, 53)];
    inviteFriend.anchorPoint=ccp(0.5,1.0);
    inviteFriend.position = ccp(CCDirector.sharedDirector.winSize.width/2.0, CCDirector.sharedDirector.winSize.height - titleBarHeightIn - 7); //7 is gap between button and titleBar
    [self addChild:inviteFriend z:1];
    
    //set viewing window for table layer
    viewSize = CGSizeMake(CCDirector.sharedDirector.winSize.width, backgroundTopClip.position.y - backgroundTopClip.contentSize.height - tabBarHeight); 
    
    //preload textures
    backgroundTexture = [[CCTextureCache sharedTextureCache] addImage:@"cellBackgroundWithArrow.png"];
    selectedBackgroundTexture = [[CCTextureCache sharedTextureCache] addImage:@"selectedCellBackground.png"];
    CCSprite* tempSprite = [CCSprite spriteWithTexture:backgroundTexture];
    
    //populateArray must be called before setupTableWithCellHeight
    [self reloadProperties];
    [self setupTableWithCellHeight:tempSprite.contentSize.height];
    
    //schedule update calls the update method in TableLayer
    [self scheduleUpdate];
}

-(void) reloadProperties
{
    //refresh object references (in case interface layer now points to new objects)
    players=interfaceLayer.players;
    recommendedFriends=interfaceLayer.recommendedFriends;
    
    //set up indices that separate out each section of the table
    //Set number of cells based on sections, first section will have 2 and a section title, next two depend on arrays
    numCells = 2 + [recommendedFriends count] + [players count] + 3; //3 = number of section titles
    indexThresholdYourPlayers = 2 + 1; //1 = section title
    indexThresholdRecFriends = indexThresholdYourPlayers + [recommendedFriends count] + 1; //1 = section title
    indexThresholdAllFriends = numCells;
}

-(SWTableViewCell *)tableView:(SWTableView *)table cellAtIndex:(NSUInteger)i
{
    
    SWTableViewNodeCell *tableCell = [table dequeueCell];
    
    if (!tableCell) {
        tableCell = [[WrapperCell alloc] init];
        tableCell.anchorPoint=ccp(0,0);
    }
    else
        [tableCell removeAllChildrenWithCleanup:YES];
    tableCell.idx = i;
    
    CCNode* cell;
    
    //create section titles
    if (i==0)
    {
        cell = [self sectionTitle:@"RANDOM PLAYERS"];
    }
    else if (i==indexThresholdYourPlayers)
    {
        cell = [self sectionTitle:@"RECOMMENDED"];
    }
    else if (i==indexThresholdRecFriends)
    {
        cell = [self sectionTitle:@"ALL FRIENDS"];
    }
    
    else
    {
        //cell background
        CCSprite* emptyBackground = [CCSprite spriteWithTexture:backgroundTexture];
        emptyBackground.anchorPoint=ccp(0.5,0.5);
        CCSprite* selectedBackground = [CCSprite spriteWithTexture:selectedBackgroundTexture];
        selectedBackground.anchorPoint=emptyBackground.anchorPoint;
        
        CCMenuItemSprite* cellItem = [CCMenuItemSprite itemWithNormalSprite:emptyBackground selectedSprite:selectedBackground
                                                                     target:self selector:@selector(cellClicked:)];
        
        //set tag of item so that when it's clicked we can get the index
        cellItem.tag = i;
        cellItem.anchorPoint=ccp(0,0);
        cellItem.position = ccp(0,0);
        
        //We will set action, name, FB-username based on cell
        NSString* action = @"PLAY";
        NSString* name;
        NSString *uname; //facebook username
        CCSprite* fbSprite; //facebook profile picture sprite
        
        //Set friend name
        //arrayIndex is used to convert "i", which is the row number of the cell, to the index of the array for the section the cell is in
        NSUInteger arrayIndex = i - 1; //-1 accounts for the previous section title
        //First section has random friend and random player
        if (i<indexThresholdYourPlayers)
        {
            if (i==1)
            {
                name = @"Random Friend";
                fbSprite = [self fbSpriteWithDefault:@"RedGhost.png" isOnline:NO username:nil index:nil]; //static image
            }
            else
            {
                name = @"Random";
                fbSprite = [self fbSpriteWithDefault:@"WhiteGhost.png" isOnline:NO username:nil index:nil]; //static image
            }
        }
        //Second section has recommended friends, using play or invite depending on whether the friend plays the game
        else if (i<indexThresholdRecFriends)
        {
            arrayIndex -= indexThresholdYourPlayers;
            name = [[recommendedFriends objectAtIndex:arrayIndex] objectForKey:@"name"];
            name = [InterfaceLayer shortName:name];
            uname = [[recommendedFriends objectAtIndex:arrayIndex] objectForKey:@"username"];
            fbSprite = [self fbSpriteWithDefault:@"WhiteGhost.png" isOnline:YES username:uname index:i];
            if (arrayIndex == 2 || arrayIndex >= [players count])
                action = @"INVITE!";
        }
        //Third section has friends who play the game
        else
        {
            arrayIndex -= indexThresholdRecFriends;
            name = [[players objectAtIndex:arrayIndex] objectForKey:@"name"];
            name = [InterfaceLayer shortName:name];
            uname = [[players objectAtIndex:arrayIndex] objectForKey:@"username"];
            fbSprite = [self fbSpriteWithDefault:@"WhiteGhost.png" isOnline:YES username:uname index:i];
        }
        
        //Text labels for cells
        ccColor3B textColor = ccc3(223, 228, 227); //light grey
        
        CCLabelTTF* actionLabel = [CCLabelTTF labelWithString:action fontName:@"ghosty" fontSize:16];
        actionLabel.color=textColor;
        actionLabel.anchorPoint=ccp(1.0,0.5);
        actionLabel.position = ccp(cellItem.contentSize.width - 25,cellItem.contentSize.height/2.0);
        
        //ensures that the name truncates and doesn't run off and overlap with the end of the cell
        float widthFromNameToAction = actionLabel.position.x - actionLabel.contentSize.width - 70; //70 = position of nameLabel (anchored on left)
        CGSize nameDim = [name sizeWithFont:[UIFont fontWithName:@"Nexa Bold" size:18] forWidth:widthFromNameToAction lineBreakMode:NSLineBreakByTruncatingTail];
        CCLabelTTF* nameLabel = [CCLabelTTF labelWithString:name dimensions:nameDim hAlignment:kCCTextAlignmentCenter lineBreakMode:kCCLineBreakModeTailTruncation fontName:@"Nexa Bold" fontSize:18];
        nameLabel.color=textColor;
        nameLabel.anchorPoint=ccp(0,0.5);
        nameLabel.position = ccp(70,cellItem.contentSize.height/2.0);
        
        [cellItem addChild:actionLabel];
        [cellItem addChild:fbSprite];
        [cellItem addChild:nameLabel];
        
        //CCMenuTouchSwallow ensures that the cells don't swallow touches - allows for scrolling of table
        cell = [CCMenuNoSwallow menuWithItems:cellItem, nil];
        cell.contentSize = cellItem.contentSize;
        cell.position = ccp(0,0);
        cell.anchorPoint=ccp(0,0);
    }
    tableCell.cellSize = cell.contentSize;
    tableCell.node = cell;
	
    return tableCell;
}

-(CGSize) tableView:(SWTableView*)table cellSizeForIndex: (NSUInteger) index
{
    if ([self isSectionTitleAtIndex:index])
        return CGSizeMake(320, 40);
    else
        return CGSizeMake(320, 60);
}

-(BOOL) isSectionTitleAtIndex:(NSUInteger) i
{
    if (i==0 || i==indexThresholdYourPlayers || i==indexThresholdRecFriends)
    {
        return YES;
    }
    return NO;
}

//method for SWTableViewDataSource
-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
    return numCells;
}

-(void) cellClicked: (CCMenuItem*) itemClicked
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
    Data* data = [Data sharedData];
    int i = itemClicked.tag;
    
    //arrayIndex is used to convert "i", which is the row number of the cell, to the index of the array for the section the cell is in
    NSUInteger arrayIndex = i - 1; //-1 accounts for the previous section title
    //Random section
    if (i<indexThresholdYourPlayers)
    {
		//If random friend, start a game with a random available friend
		if (arrayIndex == 0)
		{
			if ([players count] < 1)
				[MGWU showMessage:@"Already playing with all friends" withImage:nil];
			else
			{
				int randPlayer = arc4random()%[players count];
                GameLayer* gameLayer = [[GameLayer alloc] init];
                data.opponent = [[players objectAtIndex:randPlayer] objectForKey:@"username"];
				data.opponentName = [InterfaceLayer shortName:[[players objectAtIndex:randPlayer] objectForKey:@"name"]];
                [self slideRightTransitionToGame:gameLayer];
			}
        }
        //If random player, load random player from the server, callback will begin game
        else
			[MGWU getRandomPlayerWithCallback:@selector(gotPlayer:) onTarget:self];
    }
    
    //If recommended friend, start a game with the friend
    else if (i<indexThresholdRecFriends)
    {
        arrayIndex -= indexThresholdYourPlayers;
		//If it's a friend who isn't playing, invite them on facebook
		if (arrayIndex == 2 || arrayIndex >= [players count])
			[MGWU inviteFriend:[[recommendedFriends objectAtIndex:arrayIndex] objectForKey:@"username"] withMessage:@"Play a game with me!"];
		GameLayer* gameLayer = [[GameLayer alloc] init];
		data.opponent = [[recommendedFriends objectAtIndex:arrayIndex] objectForKey:@"username"];
		data.opponentName = [InterfaceLayer shortName:[[recommendedFriends objectAtIndex:arrayIndex] objectForKey:@"name"]];
		data.playerName = [InterfaceLayer shortName:[user objectForKey:@"name"]];
        [self slideRightTransitionToGame:gameLayer];
    }
    //Third section has list of friends - this is handled in Interface Builder and prepareForSegue in the UIKit project
    else
    {
        arrayIndex -= indexThresholdRecFriends;

		GameLayer* gameLayer = [[GameLayer alloc] init];
		data.opponent = [[players objectAtIndex:arrayIndex] objectForKey:@"username"];
		data.opponentName = [InterfaceLayer shortName:[[players objectAtIndex:arrayIndex] objectForKey:@"name"]];
		data.playerName = [InterfaceLayer shortName:[user objectForKey:@"name"]];
        
        [self slideRightTransitionToGame:gameLayer];
    }
    
}

-(void)gotPlayer:(NSDictionary*)p
{
    Data* data = [Data sharedData];
	//If player doesn't exist (no player of that username), do nothing
	if (!p)
		return;

	//Start game with player
    GameLayer* gameLayer = [[GameLayer alloc] init];
    data.opponent = [p objectForKey:@"username"];
	//FIX THIS LATER TO CHECK IF USER IS FRIEND
    data.opponentName = [p objectForKey:@"username"];
	data.playerName = [user objectForKey:@"username"];
    [self slideRightTransitionToGame:gameLayer];
}



-(void)slideRightTransitionToGame: (GameLayer*) gameLayer
{
    //starting a game, so game is nil.
    Data* data = [Data sharedData];
    data.game = nil;
    [gameLayer setupGame];
    
    //slide in from the right
    CCTransitionSlideInR* transition = [CCTransitionSlideInR transitionWithDuration:0.25f scene:[gameLayer sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

//reset red badge that shows players you haven't viewed yet (because now you have)
-(void) onEnter
{
    //Set new friends to 0 and set badge value to nil (when the layer is being shown these are reset)
	int diff = [interfaceLayer.playersTab.badgeString intValue];
	interfaceLayer.newFriends = 0;
	interfaceLayer.playersTab.badgeString = nil;
	int numFriends = [[NSUserDefaults standardUserDefaults] integerForKey:@"numFriends"]+diff;
	[[NSUserDefaults standardUserDefaults] setInteger:numFriends forKey:@"numFriends"];
    
    [super onEnter];
}

@end
