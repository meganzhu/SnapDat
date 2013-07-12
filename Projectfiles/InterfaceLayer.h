//
//  InterfaceLayer.h
//  Ghost
//
//  Created by Brian Chu on 10/29/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "StyledCCLayer.h"
@class TableLayer;
@class GamesTableLayer;
@class PlayersTableLayer;
@class InviteTableLayer;
@class BadgedCCMenuItemSprite;

typedef enum {
    GamesItemTag = 1,
    PlayersItemTag = 2,
    InviteItemTag = 3,
    } TabMenuItem;

@interface InterfaceLayer : StyledCCLayer
{
    CCMenuItem* disabledItem;
    
    BadgedCCMenuItemSprite* gamesTab;
    BadgedCCMenuItemSprite* playersTab;
    BadgedCCMenuItemSprite* inviteTab;
    
    GamesTableLayer* gamesTableLayer;
	PlayersTableLayer* playersTableLayer;
    InviteTableLayer* inviteTableLayer;
    
    float tabBarHeight;
    
	UIAlertView *updateAlertView;
	NSString *updateURL;
	int counter;
    
}
@property float tabBarHeight;
@property TableLayer* currentTableLayer;
@property NSMutableArray* games,*gamesYourTurn, *gamesTheirTurn, *gamesCompleted, * players,* recommendedFriends;
@property NSMutableArray* nonPlayers; //InviteTableLayer
@property BadgedCCMenuItemSprite* gamesTab,* playersTab,* inviteTab; //tab menu items
@property int newFriends;

+(id) scene;
+(InterfaceLayer*) sharedInstance;
-(id) initWithTableLayer: (TableLayer*) tableLayer;
-(void) refresh;
-(void) gamesClick;
-(void) playersClick;
-(void) inviteClick;
+ (NSString*)shortName:(NSString*)friendname;
@end
