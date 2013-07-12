//
//  StartLayer.h
//  Ghost
//
//  Created by Brian Chu on 10/29/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "StyledCCLayer.h"

@class CCControlButton;
@interface StartLayer : StyledCCLayer
{
	//BOOL to keep track of whether the player is in the game (as opposed to in more games / how to play)
    BOOL inGame;
    
    CCControlButton *playButton;
	CCControlButton *moreGamesButton;
}
+(id) scene;

@end
