//
//  InviteTableLayer.h
//  Ghost
//
//  Created by Brian Chu on 11/15/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "TableLayer.h"

@interface InviteTableLayer : TableLayer <UISearchBarDelegate>
{
    UISearchBar* searchBar;
	
    //arrays for search cell items
//	NSMutableArray *filteredArrayOfMenus;
    
    //Arrays to hold list of players, and filtered list of players for search
	NSMutableArray *nonPlayers;
    NSMutableArray *filteredNonPlayers;
    
    NSUInteger indexThresholdNonPlayers;
    NSUInteger indexThresholdFilterNonPlayers;
    NSUInteger indexThresholdAllFriends;
    
    BOOL searchTableViewActive;
}
@end
