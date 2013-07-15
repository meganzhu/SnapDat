//Gamelayer.h
//Pics game
//created by Megan Zhu
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//from Brian Chu's ghost template.

#import "StyledCCLayer.h"
#import "PromptLayer.h"
#import "PopupLayer.h"
#import "PhotoLayer.h"
#import <UIKit/UIImage.h>
#import "Data.h"

@class CCControlButton, PopupLayer;
@interface GameLayer : StyledCCLayer <PopupDelegate>
{
    //access to our singleton
    Data* data;
    
    //Chat icon in nav bar
	CCMenuItemImage* chatButton;
    CCLabelTTF* chatLabel;
	

    
    CCControlButton* play;
	CCControlButton* re;
    CCControlButton* moreGames;
    
    //Variable to control reloading of game
	BOOL inChat;
	BOOL inGuess;
    
    //Prompt layer and Photo layer and PopupViewController to push onto scene
    PromptLayer* promptLayer;
    PhotoLayer* photoLayer;
    __weak PopupLayer* popup;
    
}


-(CCScene*) sceneWithSelf;
-(void) setupGame;
- (void)loadGame;
- (void)quit;
-(void) refresh;
@end