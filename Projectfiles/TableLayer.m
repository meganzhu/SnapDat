//
//  ScrollTableLayer.m
//  Scrolling
//
//  Copyright 2013 MakeGamesWithUs Inc.
//  Created by Brian Chu
//

#import "TableLayer.h"
#import "ChatLayer.h"
#import "SWTableViewCell.h"
#import "CCControlButton.h"
#import "CCScale9Sprite.h"


@implementation SWTableViewNodeCell
@synthesize node;

-(void)setNode:(CCNode *)s {
    if (node) {
        [self removeChild:node cleanup:NO];
    }
    s.anchorPoint = s.position = CGPointZero;
    node = s;
    [self addChild:node];
}
-(CCNode *)node {
    return node;
}
-(void)reset {
    //[super reset];
    if (node) {
        [self removeChild:node cleanup:NO];
    }
    node = nil;
}
@end

@implementation WrapperCell
@synthesize cellSize;
@end

@implementation TableLayer
@synthesize tableContentSize, hasVariableCellSize;
@synthesize tableView, tabBarHeight;

-(id) init
{
    self = [super init];
    return self;
}

//abstract method, overriden by subclasses
-(void) setupWithTabBarHeight: (float) tabBarHeightIn titleBarHeight: (float) titleBarHeight
{}

//overloaded helper method
-(void) setupTableWithCellHeight: (float) cellHeight
{
    [self setupTableWithCellHeight:cellHeight hasVariableCellSize:YES];
}
-(void) setupTableWithCellHeight: (float) cellHeight hasVariableCellSize: (BOOL) hasVarCell
{
    //Size of one cell in the table
    cellSize = CGSizeMake(viewSize.width, cellHeight);
    
    //initialize the object that will feed data to our TableView
//    dataSource = [[SWTableDataSourceWrapper alloc] initWithMaxCellSize:cellSize andArrayOfCells:arrayOfMenus andHasVariableCellSize:hasVarCell];
    hasVariableCellSize=hasVarCell;
    
    float tableHeight=0;
    for (NSUInteger i = 0; i<[self numberOfCellsInTableView:nil]; i++)
    {
        CGSize size = [self tableView:nil cellSizeForIndex:i];
        [cellHeights setObject:@(size.height) atIndexedSubscript:i];
        tableHeight+=size.height;
    }
    tableContentSize=CGSizeMake(cellSize.width, tableHeight);
    
    //size of the "viewing window"
    //for example, a menu that pops up in-game will be smaller than full-screen
    //the screenSize width should be the same as the cellSize width
    tableView = [SWTableView viewWithDataSource:self size:viewSize];
	
	//add pull to refresh
	if (![self isKindOfClass:[ChatLayer class]])
		[tableView addPullToRefresh];
    
    //set the delegate to this class
    //For this to work, this class must implement the table:cellTouched: method (see after this method)
    tableView.delegate=self;
    
    //table view does not clip off cells that go over the view size
    tableView.clipsToBounds=YES;
    
    //direction of the table.
    tableView.direction = SWScrollViewDirectionVertical;
    
    //position
    tableView.position = ccp(0,tabBarHeight);

    //SWTableViewFillTopDown fills the table with cell #1 at the top
    //BottomUp fills the table with cell #n (the last index) at the top
    tableView.verticalFillOrder = SWTableViewFillTopDown; //default is TopDown
    
    [self addChild:tableView];
}

//method for SWTableViewDelegate
//if delegate is set, called when a cell is touched
-(void)tableView:(SWTableView *)table cellTouched:(SWTableViewCell *)cell {
 //get the index # of the cell that was touched using cell.idx
}

-(void) reloadData
{
    [self removeChild:tableView cleanup:YES];
    
    [self reloadProperties];
    
    float tableHeight=0;
    for (NSUInteger i = 0; i<[self numberOfCellsInTableView:nil]; i++)
    {
        CGSize size = [self tableView:nil cellSizeForIndex:i];
        [cellHeights setObject:@(size.height) atIndexedSubscript:i];
        tableHeight+=size.height;
    }
    tableContentSize=CGSizeMake(cellSize.width, tableHeight);
    
    tableView = [SWTableView viewWithDataSource:self size:viewSize];
    
	tableView.delegate = self;
	
	//add pull to refresh
	if (![self isKindOfClass:[ChatLayer class]])
		[tableView addPullToRefresh];
    
    //direction of the table.
    tableView.direction = SWScrollViewDirectionVertical;
    
    tableView.clipsToBounds=YES;
    
    tableView.position = ccp(0,tabBarHeight);

    //SWTableViewFillTopDown fills the table with cell #1 at the top
    //BottomUp fills the table with cell #n (the last index) at the top
    tableView.verticalFillOrder = SWTableViewFillTopDown; //default is TopDown
    
    [tableView reloadData];
    
    [self addChild:tableView];
}
-(void) reloadProperties{};

//return a sprite with the default picture
//if online, starts a background process to set the sprite's image with the actual Facebook profile picture - downloaded asynchronously
-(CCSprite*) fbSpriteWithDefault: (NSString*)image isOnline:(BOOL)isOnline username:(NSString*)uname index:(NSUInteger)idx
{
    CCSprite* fbSprite = [CCSprite spriteWithFile:image];
    fbSprite.anchorPoint=ccp(0,0);

    //stretch to fill cell
    if (fbSprite.contentSize.height>fbSprite.contentSize.width)
        fbSprite.scale = 40.0/fbSprite.contentSize.height;
    else
        fbSprite.scale = 40.0/fbSprite.contentSize.width;
    
    fbSprite.position = ccp(10,10);
    if (isOnline)
        [ProfilePictureCacheCocos setProfilePicture:uname forSprite:fbSprite tableView:tableView index:idx];
    return fbSprite;
}

//helper method for returning section titles in the table
-(CCNode*) sectionTitle: (NSString*) titleStr
{
    CCNode* container = [CCNode node];
    container.anchorPoint=ccp(0,0);
    container.contentSize=CGSizeMake(320, 40);
    CCLabelTTF* titleLabel = [CCLabelTTF labelWithString:titleStr fontName:@"Nexa Bold" fontSize:28];
    titleLabel.color=ccc3(223.0,228.0, 227.0);
    titleLabel.anchorPoint=ccp(0,1);
    titleLabel.position = ccp(5,container.contentSize.height - 5);
    
    CCSprite* divider = [CCSprite spriteWithFile:@"sectionTitleBar.png"];
    divider.anchorPoint=ccp(0,1);
    divider.position = ccp(5,container.contentSize.height - 32);
    
    [container addChild:titleLabel];
    [container addChild:divider];
    
    return container;
}

-(void) refresh
{
    [[InterfaceLayer sharedInstance] refresh];
}

-(void) update: (ccTime) delta
{
    KKInput* input = [KKInput sharedInput];
    
    if ([input anyTouchBeganThisFrame])
    {
        for (SWTableViewCell* cell in tableView.cellsUsed)
        {
            for (CCMenu* menu in cell.children)
            {
                for (CCMenuItem* item in menu.children)
                {
                    if ([item isKindOfClass:[CCMenuItem class]] && item.isSelected)
                    {
                        [item unselected];
                        
                        //if touch is on a cell outside the bounds of the table layer, ignore that cell selection
                        CGPoint inputBeganLoc = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
                        if(inputBeganLoc.y < tabBarHeight || inputBeganLoc.y > tabBarHeight+viewSize.height)
                        {
                            [item setIsEnabled:NO];
                        }
                        firstTouchedMenuItem=item;
                        firstTouchLocation = [input locationOfAnyTouchInPhase:KKTouchPhaseBegan];
                    }
                }
            }
        }
    }
    //reset the state when touch lifted
    else if (input.anyTouchEndedThisFrame)
    {
        [firstTouchedMenuItem setIsEnabled:YES];
        firstTouchedMenuItem=nil;
    }
    else if(firstTouchedMenuItem)
    {
        //make sure the touch has not moved much before you allow the item to be selected
        //touch delay allows for flicking gesture on the table without triggering selection
        
        //HACK: input location checking
        CGPoint inputBeganLoc = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        if (firstTouchedMenuItem.isEnabled && ccpFuzzyEqual([input locationOfAnyTouchInPhase:KKTouchPhaseAny], firstTouchLocation, 1) && inputBeganLoc.y < tabBarHeight+viewSize.height)
        {
            if (touchDelay>1)
            {
                [firstTouchedMenuItem selected];
            }
            else
                touchDelay++;
        }
        
        //disable the touch
        else
        {
            [firstTouchedMenuItem unselected];
            [firstTouchedMenuItem setIsEnabled:NO];
            touchDelay=0;
        }
        
    }
}

//method for SWTableViewDataSource
-(SWTableViewCell *)tableView:(SWTableView *)table cellAtIndex:(NSUInteger)index
{
    @throw [NSException exceptionWithName:@"SWTableViewDataSource Invalid Method"
                                   reason:@"You must override table:cellAtIndex: in a subclass"
                                 userInfo:nil];
}

-(CGSize) tableView:(SWTableView*)table cellSizeForIndex: (NSUInteger) index
{
    @throw [NSException exceptionWithName:@"SWTableViewDataSource Invalid Method"
                                   reason:@"You must override cellSizeForIndex: in a subclass"
                                 userInfo:nil];
}

//top of cell 1 to top of cell 2
-(float) tableView:(SWTableView*)table heightFromCellIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2
{
    float height = 0;
    for (NSUInteger i = index1; i<index2; i++)
    {
        height += ((CGSize)[self tableView:table cellSizeForIndex:i]).height;
    }
    return height;
}

//method for SWTableViewDataSource
-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
    @throw [NSException exceptionWithName:@"SWTableViewDataSource Invalid Method"
                                   reason:@"You must override numberOfCellsInTableView: in a subclass"
                                 userInfo:nil];
}


@end
