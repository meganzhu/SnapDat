//
//  InviteTableLayer.m
//  Ghost
//
//  Created by Brian Chu on 11/15/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "InviteTableLayer.h"
#import "GameLayer.h"
#import "BadgedCCMenuItemSprite.h"
#import "AppDelegate.h"
#import "CCMenuNoSwallow.h"

#define INVITE_SECTIONS 3


@implementation InviteTableLayer


-(void) setupWithTabBarHeight: (float) tabBarHeightIn titleBarHeight: (float) titleBarHeightIn
{
    //set up references and properties
    tabBarHeight=tabBarHeightIn;
    interfaceLayer=[InterfaceLayer sharedInstance];
    
    //preload textures
    backgroundTexture = [[CCTextureCache sharedTextureCache] addImage:@"cellBackgroundWithArrow.png"];
    selectedBackgroundTexture = [[CCTextureCache sharedTextureCache] addImage:@"selectedCellBackground.png"];
    
    //*****Setup search box
    CGSize screenSize = CCDirector.sharedDirector.winSize;
    
    //UIKit:
    //Note: Position of UIKit objects is relative to upper left corner, with the anchor point at the upper left corner (0,1)
    //CGRectMake(x,y,width,height)
    [[UISearchBar appearance] setBackgroundImage:[[UIImage imageNamed:@"SearchBarBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
	[[UISearchBar appearance] setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0.0, 1.0)];
	[[UISearchBar appearance] setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarTextField.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)] forState:UIControlStateNormal];
	[[UISearchBar appearance] setImage:[UIImage imageNamed:@"SearchBarIcon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
	
	[[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
																								  [UIColor clearColor],
																								  UITextAttributeTextColor,
																								  [UIColor clearColor],
																								  UITextAttributeTextShadowColor,
																								  nil]
																						forState:UIControlStateNormal];
	
	[[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundImage:[[UIImage imageNamed:@"SearchBarCancelButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    searchBar= [[UISearchBar alloc] initWithFrame:CGRectMake(0,titleBarHeightIn-1, screenSize.width, 44)]; //-1 eliminates gap between searchbar and nav bar
    [[[CCDirector sharedDirector] view] addSubview:searchBar]; //add UIKit view to 
    
    searchBar.delegate = self;
    searchBar.placeholder = @"Search"; //placeholder text
    searchBar.barStyle = UIBarStyleBlackOpaque;
	[searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
	[searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    //customize the keyboard for UITextField
	for(UIView *subView in searchBar.subviews)
	{
		if([subView isKindOfClass: [UITextField class]])
		{
			[(UITextField *)subView setKeyboardAppearance: UIKeyboardAppearanceAlert];
			[(UITextField *)subView setTextColor:[UIColor whiteColor]];
		}
    }
    
    
    //Rest of layer:
    viewSize = CGSizeMake(CCDirector.sharedDirector.winSize.width, CCDirector.sharedDirector.winSize.height - tabBarHeightIn - titleBarHeightIn - 44); //44 = searchBox height
    CCSprite* tempSprite = [CCSprite spriteWithTexture:backgroundTexture];
	
    //populateArray must be called before setupTableWithCellHeight
    [self reloadProperties];
    filteredNonPlayers = [NSMutableArray arrayWithCapacity:[nonPlayers count]/4]; //[nonPlayers count]/4 is the ballpark expected highest number of people a search will ever turn up for one letter
    [self setupTableWithCellHeight:tempSprite.contentSize.height hasVariableCellSize:YES];
    
    //schedule update calls the update method in TableLayer
    [self scheduleUpdate];
}

-(void) reloadProperties
{
    //refresh object references (in case interface layer now points to new objects)
    nonPlayers = interfaceLayer.nonPlayers;
    //Set number of cells depending on whether search filter is active
    if (searchTableViewActive)
        numCells = max(1,[filteredNonPlayers count]); //there will always be at least 1 cell - if count==0, we'll have a "no results" cell
    else
        numCells = [nonPlayers count];
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
	if (searchTableViewActive && [filteredNonPlayers count] == 0)
    {
		//Set up "No Results" display
        cell = [CCNode node];
        cell.anchorPoint=ccp(0,0);
        cell.contentSize = CGSizeMake(320, 132);
        
        CCLabelTTF* nameLabel = [CCLabelTTF labelWithString:@"No Results" fontName:@"HelveticaNeue-Bold" fontSize:20];
        nameLabel.color=ccWHITE;
        nameLabel.anchorPoint=ccp(0.5,0.5);
        nameLabel.position = ccp(cell.contentSize.width/2.0, cell.contentSize.height/2.0);
        [cell addChild:nameLabel];
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
        NSString* action = @"INVITE!";
        NSString* name;
        NSString* uname; //facebook username
        if (searchTableViewActive)
        {
            name = [InterfaceLayer shortName:[[filteredNonPlayers objectAtIndex:i] objectForKey:@"name"]];
            uname = [[filteredNonPlayers objectAtIndex:i] objectForKey:@"username"];
        }
        else
        {
            name = [InterfaceLayer shortName:[[nonPlayers objectAtIndex:i] objectForKey:@"name"]];
            uname = [[nonPlayers objectAtIndex:i] objectForKey:@"username"];
        }
        
        //FB profile picture
        CCSprite* fbSprite = [self fbSpriteWithDefault:@"WhiteGhost.png" isOnline:YES username:uname index:i];
        
        //Text labels for cells
        ccColor3B textColor = ccc3(223, 228, 227); //light grey
        
        CCLabelTTF* actionLabel = [CCLabelTTF labelWithString:action fontName:@"ghosty" fontSize:16];
        actionLabel.color=textColor;
        actionLabel.anchorPoint=ccp(1.0,0.5);
        actionLabel.position = ccp(cellItem.contentSize.width - 25,cellItem.contentSize.height/2.0);
        
        //ensures that the name truncates and doesn't run off and overlap with the end of the cell
        float widthFromNameToAction = actionLabel.position.x - actionLabel.contentSize.width - 70 - 5; //70 = position of nameLabel (anchored on left), 5 = padding
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
    if (searchTableViewActive && [filteredNonPlayers count]==0)
        return CGSizeMake(320, 132);
    else
        return CGSizeMake(320, 60);
}

//method for SWTableViewDataSource
-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
    return numCells;
}

-(void) cellClicked: (CCMenuItem*) itemClicked
{
    Data* data = [Data sharedData];
    GameLayer* gameLayer = [[GameLayer alloc] init];
    int i = itemClicked.tag;
    
    //get data for the player we selected
    NSDictionary* playerData;
    if (searchTableViewActive)
    {
        playerData = [filteredNonPlayers objectAtIndex:i];
    }
    else
        playerData = [nonPlayers objectAtIndex:i];
    
    //popup the invite friend screen
	[MGWU inviteFriend:[playerData objectForKey:@"username"] withMessage:@"Play a game with me!"];

    //Activate game layer
    data.opponent = [playerData objectForKey:@"username"];
    data.opponentName = [InterfaceLayer shortName:[playerData objectForKey:@"name"]];
    data.playerName = [InterfaceLayer shortName:[user objectForKey:@"name"]];
    [gameLayer setupGame];
    
    //slide in scene from the right
    CCTransitionSlideInR* transition = [CCTransitionSlideInR transitionWithDuration:0.25f scene:[gameLayer sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

//overrides super class update
-(void) update:(ccTime)delta
{
    if (KKInput.sharedInput.anyTouchBeganThisFrame)
        [searchBar resignFirstResponder]; //hide keyboard
    
    [super update:delta];
}


#pragma mark SEARCH BAR

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 0)
    {
        searchTableViewActive = YES;
    }
    else
        searchTableViewActive=NO;
    
	[self filterContentForSearchText:searchText];
    
    [self reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[filteredNonPlayers removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (NSDictionary *f in nonPlayers)
	{
		//Match names if they contain the searched value as a substring
		BOOL match = FALSE;
		NSArray *names = [[f objectForKey:@"name"] componentsSeparatedByString:@" "];
		for (NSString *name in names)
		{
			NSComparisonResult result = [name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
			if (result == NSOrderedSame)
			{
				match = TRUE;
			}
		}
		if (match)
			[filteredNonPlayers addObject:f];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder]; //hide keyboard
}

//make sure the search box is removed when the layer is removed
-(void) onExitTransitionDidStart
{
    [searchBar removeFromSuperview];
    [super onExitTransitionDidStart];
}

//make sure to reattach the search box when the layer is added again
-(void) onEnter
{
    [[[CCDirector sharedDirector] view] addSubview:searchBar];
    [super onEnter];
}

@end
