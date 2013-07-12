//
//  ScrollTableLayer.h
//  Scrolling
//
//  Copyright 2013 MakeGamesWithUs Inc.
//  Created by Brian Chu
//

#import "InterfaceLayer.h"
#import "SWTableView.h"
#import "ProfilePictureCacheCocos.h"
#import "StyledCCLayer.h"
#import "SWTableViewCell.h"

@class InterfaceLayer;

//Private class
@interface SWTableViewNodeCell : SWTableViewCell {
    CCNode *node;
}
@property (nonatomic, retain) CCNode *node;
@end

//Private class:
@interface WrapperCell : SWTableViewNodeCell
@property CGSize cellSize;
@end

//The <> syntax declares that ScrollTableLayerExample "implements" the SWTableViewDelegate protocol and the SWTableViewDataSource protocol.
//Protocols are Objective-C's equivalent of Java interfaces
@interface TableLayer : StyledCCLayer <SWTableViewDelegate, SWTableViewDataSource>
{
    InterfaceLayer* interfaceLayer;
    
    CCTexture2D* backgroundTexture;
    CCTexture2D* selectedBackgroundTexture;
    
    SWTableView * tableView;
    NSUInteger numCells;
    
    CCMenuItem* firstTouchedMenuItem;
    CGPoint firstTouchLocation;
    int touchDelay;
    
    float tabBarHeight;
    
    CGSize viewSize;
    
    //SWTableViewDataSource
    NSMutableArray* cellHeights;
    NSMutableArray* cellWidths;
    CGSize cellSize;
    
    
    
}
@property (nonatomic) SWTableView* tableView;
@property (nonatomic) float tabBarHeight;

-(void) update: (ccTime) delta;
-(void) refresh;
-(void) reloadData;
-(void) reloadProperties;
-(CCSprite*) fbSpriteWithDefault: (NSString*)image isOnline:(BOOL)isOnline username:(NSString*)uname index:(NSUInteger)idx;
-(CCNode*) sectionTitle: (NSString*) title;
-(void) setupWithTabBarHeight: (float) tabBarHeight titleBarHeight: (float) titleBarHeight;
-(void) setupTableWithCellHeight: (float) cellHeight;
-(void) setupTableWithCellHeight: (float) cellHeight hasVariableCellSize: (BOOL) hasVarCell;

@end
