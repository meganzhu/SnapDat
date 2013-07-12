//
//  GamesTableLayer.m
//  Ghost
//
//  Created by Brian Chu on 10/30/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "GamesTableLayer.h"
#import "GameLayer.h"
#import "AppDelegate.h"
#import "CCControlButton+NoSwallow.h"
#import "CCMenuNoSwallow.h"

#define GAMES_SECTIONS 3

@implementation GamesTableLayer

-(void) setupWithTabBarHeight: (float) tabBarHeightIn titleBarHeight: (float) titleBarHeightIn
{
    //set up references and properties
    tabBarHeight=tabBarHeightIn;
    interfaceLayer=[InterfaceLayer sharedInstance];
    
    //add an image that is placed on top of the table to hide cells that are at the top of the table
    //18 would be gap between button and top of view (handled by backgroundTopClip)
    [self addBackgroundTopClip];
    backgroundTopClip.position = ccp(backgroundTopClip.position.x, backgroundTopClip.position.y - titleBarHeightIn);
    
    //new game button
    CCControlButton* newGame = [self standardButtonWithTitle:@"NEW GAME" font:@"Nexa Bold" fontSize:18 target:interfaceLayer selector:@selector(playersClick) preferredSize:CGSizeMake(320, 53)];
    newGame.anchorPoint = ccp(0.5,1.0); //upper-left corner
    newGame.position = ccp(CCDirector.sharedDirector.winSize.width/2.0, CCDirector.sharedDirector.winSize.height - titleBarHeightIn - 7); //7 is gap between button and titleBar
    [self addChild:newGame z:1];
    
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
    gamesCompleted=interfaceLayer.gamesCompleted;
    gamesYourTurn=interfaceLayer.gamesYourTurn;
    gamesTheirTurn=interfaceLayer.gamesTheirTurn;
    
    //set up indices that separate out each section of the table
    numCells = [gamesYourTurn count] + [gamesTheirTurn count] + [gamesCompleted count] + 3; //3 = number of section titles
    indexThresholdGamesYourTurn= [gamesYourTurn count] + 1; //1 = section title
    indexThresholdGamesTheirTurn = indexThresholdGamesYourTurn + [gamesTheirTurn count] + 1; //1 = section title
    indexThresholdGamesCompleted = numCells;
}


//create an array that contains all the cells for the table
-(SWTableViewCell *)tableView:(SWTableView *)table cellAtIndex:(NSUInteger)i
{
    SWTableViewNodeCell *tableCell = [table dequeueCell];
    
    if (!tableCell) {
        tableCell = [[WrapperCell alloc] init];
        tableCell.anchorPoint=ccp(0,0);
    }
    else
        [tableCell removeAllChildrenWithCleanup:YES];
    
    CCNode* cell;
    
    //create section titles
    if (i==0)
    {
        cell = [self sectionTitle:@"YOUR TURN"];
    }
    else if (i==indexThresholdGamesYourTurn)
    {
        cell = [self sectionTitle:@"WAITING..."];
    }
    else if (i==indexThresholdGamesTheirTurn)
    {
        cell = [self sectionTitle:@"COMPLETED"];
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
        
        NSDictionary* gameData;
        NSString* action = @"VIEW";
        NSString* name;
        
        //Set action text based on the state of the game
        //arrayIndex is used to convert "i", which is the row number of the cell, to the index of the array for the section the cell is in
        NSUInteger arrayIndex = i - 1; //-1 accounts for the previous section title
        if (i<indexThresholdGamesYourTurn)
        {
            gameData = [gamesYourTurn objectAtIndex:arrayIndex];
            action = @"PLAY";
        }
        else if (i<indexThresholdGamesTheirTurn)
        {
            arrayIndex -= indexThresholdGamesYourTurn;
            gameData = [gamesTheirTurn objectAtIndex:arrayIndex];
        }
        else
        {
            arrayIndex -= indexThresholdGamesTheirTurn;
            gameData = [gamesCompleted objectAtIndex:arrayIndex];
            action = [[[[gameData objectForKey:@"gamedata"] objectForKey:[user objectForKey:@"username"]] uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            while ([action length] < 5)
            {
                action = [action stringByAppendingString:@">"];
            }
        }
        
        //Set name as friendName (if you're facebook friends) or username
        name = [gameData objectForKey:@"friendName"];
        if (!name)
        {
            NSArray* players = [gameData objectForKey:@"players"];
            if ([[players objectAtIndex:0] isEqualToString:[user objectForKey:@"username"]])
                name = [players objectAtIndex:1];
            else
                name = [players objectAtIndex:0];
            name = [name stringByReplacingOccurrencesOfString:@"_" withString:@"."];
            
        }
        else
        {
            name = [InterfaceLayer shortName:name];
        }
        
        //FB profile picture
        NSString *uname;
        NSArray* players = [gameData objectForKey:@"players"];
        if ([[players objectAtIndex:0] isEqualToString:[user objectForKey:@"username"]])
            uname = [players objectAtIndex:1];
        else
            uname = [players objectAtIndex:0];
        
        CCSprite* fbSprite = [self fbSpriteWithDefault:@"WhiteGhost.png" isOnline:YES username:uname index:i];
        
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
        
        //Add chat icon indicator next to profile picture if there are new messages
        int newmessages = [[gameData objectForKey:@"newmessages"] intValue];
        if (newmessages > 0)
        {
            CCSprite* chatIcon = [CCSprite spriteWithFile:@"ChatIcon.png"];
            chatIcon.contentSize=CGSizeMake(25, 20);
            chatIcon.anchorPoint=ccp(0,1.0);
            chatIcon.position = ccp(40,cellItem.contentSize.height);
            [cellItem addChild:chatIcon z:1];
        }
        
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
    if (i==0 || i==indexThresholdGamesYourTurn || i==indexThresholdGamesTheirTurn)
    {
        return YES;
    }
    return NO;
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
    return numCells;
}

-(void) cellClicked: (CCMenuItem*) itemClicked
{
    Data* data = [Data sharedData];
    GameLayer* gameLayer = [[GameLayer alloc] init];
    
    int i = itemClicked.tag;
    
    //arrayIndex is used to convert "i", which is the row number of the cell, to the index of the array for the section the cell is in
    NSUInteger arrayIndex = i - 1; //-1 accounts for the previous section title
    if (i<indexThresholdGamesYourTurn)
    {
        data.game = [gamesYourTurn objectAtIndex:arrayIndex];
    }
    else if (i<indexThresholdGamesTheirTurn)
    {
        arrayIndex -= indexThresholdGamesYourTurn;
        data.game = [gamesTheirTurn objectAtIndex:arrayIndex];
    }
    else
    {
        arrayIndex-= indexThresholdGamesTheirTurn;
        data.game = [gamesCompleted objectAtIndex:arrayIndex];
    }
    [gameLayer setupGame];
    
    //slide in scene from the right
    CCTransitionSlideInR* transition = [CCTransitionSlideInR transitionWithDuration:0.25f scene:[gameLayer sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

@end
