//
//  PlayersTableLayer.h
//  Ghost
//
//  Created by Brian Chu on 11/15/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "TableLayer.h"

@interface PlayersTableLayer : TableLayer <UITextFieldDelegate>
{
    UITextField* searchBox;
    
    //Arrays for playing friends / recommended friends
	NSMutableArray *players;
	NSMutableArray *recommendedFriends;
    
    NSUInteger indexThresholdYourPlayers;
    NSUInteger indexThresholdRecFriends;
    NSUInteger indexThresholdAllFriends;
}
@end
