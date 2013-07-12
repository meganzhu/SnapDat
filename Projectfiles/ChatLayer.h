//
//  ChatLayer.h
//  Ghost
//
//  Created by Brian Chu on 11/14/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "TableLayer.h"

@interface ChatLayer : TableLayer <UITextFieldDelegate>
{
    //Text entry box
	UITextField *message;
    //Text entry background and button
    CCSprite* toolbar;
	//Username of user to chat with
	NSString* friendID;
	//Array to save transcript of chat
	NSMutableArray *transcript;

    
    //Text entry box image for hacking around transitions
    CCSprite* textFieldBackground;
}
@property NSString* friendID;

-(CCScene*) sceneWithSelf;
-(id) initWithFriendID: (NSString*) frID;
- (void)refresh;
- (void)send;

@end
