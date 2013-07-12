//
//  GamesTableLayer.h
//  Ghost
//
//  Created by Brian Chu on 10/30/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "TableLayer.h"
@interface GamesTableLayer : TableLayer
{    
    NSUInteger indexThresholdGamesYourTurn;
    NSUInteger indexThresholdGamesTheirTurn;
    NSUInteger indexThresholdGamesCompleted;
    
    NSArray *gamesYourTurn, *gamesTheirTurn, *gamesCompleted;
}

//-(void) populateArray;
-(void) setupWithTabBarHeight: (float) tabBarHeight titleBarHeight: (float) titleBarHeight;
-(void) cellClicked: (CCMenuItem*) itemThatWasClicked;

@end
