//
//  ChatLayer.m
//  Ghost
//
//  Created by Brian Chu on 11/14/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "ChatLayer.h"
#import "AppDelegate.h"
#import "CCControlExtension.h"
#import "CCDirector+PopTransition.h"
#import "SimpleAudioEngine.h"

@implementation ChatLayer
@synthesize friendID;

//return a scene with the layer added to it
-(CCScene*) sceneWithSelf
{
    CCScene *scene = [[self superclass] scene];
	[scene addChild: self];
	return scene;
}


-(id) initWithFriendID: (NSString*) frID
{
    self = [super init];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"popForward.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"popBack.wav"];
    
    friendID=frID;
    transcript = [NSMutableArray array]; //load chat messages
    
    //Top menu bar
    [self addNavBarWithTitle:@"CHAT"];
    [self addBackButton];
    
    //Refresh button
    CCMenuItemImage* refreshItem = [CCMenuItemImage itemWithNormalImage:@"RefreshButton.png" selectedImage:nil target:self selector:@selector(refresh)];
    refreshItem.anchorPoint=ccp(1.0,0.5);
    refreshItem.position = ccp(CCDirector.sharedDirector.winSize.width, 27);
    [titleBarMenu addChild:refreshItem];
    
//*****Setup chat toolbar and chat button
    CGSize screenSize = CCDirector.sharedDirector.winSize;
    toolbar = [CCSprite spriteWithFile:@"SearchBarBackground.png"];
    toolbar.scaleX = screenSize.width/toolbar.contentSize.width;
    toolbar.anchorPoint=ccp(0,0);
    toolbar.position = ccp(0,0);

    CCMenuItemImage* chatButton = [CCMenuItemImage itemWithNormalImage:@"SendChatButton.png" selectedImage:nil target:self selector:@selector(send)];
    chatButton.anchorPoint = ccp(1.0,0.5);
    chatButton.position = ccp(screenSize.width - 7, toolbar.contentSize.height/2.0);
    CCMenu* chatButtonMenu = [CCMenu menuWithItems:chatButton, nil];
    chatButtonMenu.position=ccp(0,0);

    [toolbar addChild:chatButtonMenu];
    [self addChild:toolbar z:1];

    //Add a UITextField for inputting text - will be placed on top of toolbar
    //UIKit:
    //Note: Position of UIKit objects is relative to upper left corner
    //CGRectMake(x,y,width,height)
    [[UITextField appearance] setBackground:[[UIImage imageNamed:@"ChatTextField.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    message= [[UITextField alloc] initWithFrame:CGRectMake(7,screenSize.height-4-35, 263 , 35)];
    message.hidden=YES;
    [[[CCDirector sharedDirector] view] addSubview:message]; //add UIKit view to cocos2d view

    message.textColor=[UIColor colorWithWhite:1.0 alpha:1.0];
    message.delegate = self;
    message.placeholder = @"";
    message.borderStyle= UITextBorderStyleBezel;
    message.font = [UIFont fontWithName:@"Helvetica" size:14];
    message.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[message setAutocorrectionType:UITextAutocorrectionTypeDefault];
	[message setAutocapitalizationType:UITextAutocapitalizationTypeNone];

	//Set variables for text entry field
	[message setReturnKeyType:UIReturnKeySend];
	[message setKeyboardAppearance:UIKeyboardAppearanceAlert];
	[message setDelegate:self];

    //Register to get alerts when the keyboard is about to appear or hide - this is needed for the chat bar to slide up with the keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	//If push notifications are disabled, alert the user that the chat won't be live
	if (noPush)
		[MGWU showMessage:@"Turn on Push Notifications in Settings for live chat" withImage:nil];
    
  
    //Rest of layer:
    //44 = height of text field
    tabBarHeight=44;
    viewSize = CGSizeMake(screenSize.width, screenSize.height - 44 - titleBar.contentSize.height);
    
    CCSprite* tempSprite = [CCSprite spriteWithFile:@"graphite.png"];
    
    [self setupTableWithCellHeight:tempSprite.contentSize.height];
    
    //Get messages from server
	[MGWU getMessagesWithFriend:friendID andCallback:@selector(reload:) onTarget:self];
    
    //schedule update calls the update method in TableLayer
    [self scheduleUpdate];
    
    return self;
}

-(void) reloadProperties
{
    numCells = [transcript count];
}


//create an array that contains all the cells for the table
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
    
    
    CCNode* cell = [CCNode node];
    
    //Set size and placement of label based on message length
    NSString *text = [[transcript objectAtIndex:i] objectForKey:@"message"];
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(tableView.contentSize.width-80-40, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    //Text labels
    CCLabelTTF* messageLabel = [CCLabelTTF labelWithString:text dimensions:size hAlignment:kCCTextAlignmentCenter lineBreakMode:kCCLineBreakModeWordWrap fontName:@"HelveticaNeue" fontSize:14];
    messageLabel.color = ccBLACK;
    
    //FB profile picture
    NSString *uname = [[transcript objectAtIndex:i] objectForKey:@"from"];
    CCSprite* fbSprite;
    
    //Set up chat bubbles
    CCScale9Sprite* balloon;
    //Chat bubbles on the right side (your messages):
    if ([[[transcript objectAtIndex:i] objectForKey:@"from"] isEqualToString:[user objectForKey:@"username"]])
    {
        fbSprite = [self fbSpriteWithDefault:@"WhiteGhost.png" isOnline:YES username:uname index:i];
        fbSprite.position = ccp(tableView.contentSize.width - 6, 0);
        fbSprite.anchorPoint=ccp(1.0,0);
        
        balloon = [CCScale9Sprite spriteWithFile:@"graphite.png" capInsets:CGRectMake(17, 12, 7, 3)]; //cap insets: left, top, width, height (origin, size)
        balloon.preferedSize = CGSizeMake(max(balloon.contentSize.width, size.width + 28), max(balloon.contentSize.height,size.height + 15)); //max ensures balloon is not shrink
        balloon.position = ccp(fbSprite.position.x - fbSprite.boundingBox.size.width - 1, 0);
        balloon.anchorPoint=ccp(1.0,0);
        
        messageLabel.position=ccpAdd(balloon.position, ccp(-balloon.contentSize.width/2.0 - 3, balloon.contentSize.height/2.0));
        //-3 compensates for the fact that the center of the image is weighted towards the pointy end
        
    }
    //Chat bubbles on the left side (their messages):
    else
    {
        fbSprite = [self fbSpriteWithDefault:@"RedGhost.png" isOnline:YES username:uname index:i];
        fbSprite.position = ccp(6, 0);
        fbSprite.anchorPoint=ccp(0,0);
        
        balloon = [CCScale9Sprite spriteWithFile:@"grey.png" capInsets:CGRectMake(19, 12, 7, 3)]; //cap insets: left, top, width, height. (origin, size)
        balloon.preferedSize = CGSizeMake(max(balloon.contentSize.width, size.width + 28), max(balloon.contentSize.height,size.height + 15)); //max ensures balloon is not shrunk
        balloon.position = ccp(fbSprite.position.x + fbSprite.boundingBox.size.width + 1, 0); //we use boundingbox.size because contentSize does not account for scaling
        balloon.anchorPoint=ccp(0,0);
        
        messageLabel.position=ccpAdd(balloon.position, ccp(balloon.contentSize.width/2.0 + 3, balloon.contentSize.height/2.0));
        //3 compensates for the fact that the center of the image is weighted towards the pointy end
    }
    
    [cell addChild:fbSprite];
    [cell addChild:balloon];
    [cell addChild:messageLabel];
    
    //set cell to encompass the chat balloon and the facebook profile picture sprite.
    cell.contentSize = CGSizeMake(CCDirector.sharedDirector.winSize.width, max(balloon.preferedSize.height, fbSprite.boundingBox.size.height) + 6); //6=padding
    cell.position = ccp(0,0);
    cell.anchorPoint=ccp(0,0);
    
    
    tableCell.cellSize = cell.contentSize;
    tableCell.node = cell;
	
    return tableCell;
    
}

-(CGSize) tableView:(SWTableView*)table cellSizeForIndex: (NSUInteger) index
{
    //Set size of label based on message length
    NSString *text = [[transcript objectAtIndex:index] objectForKey:@"message"];
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(tableView.contentSize.width-80-40, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    CCSprite* balloon;
    //Right side (your messages)
    if ([[[transcript objectAtIndex:index] objectForKey:@"from"] isEqualToString:[user objectForKey:@"username"]])
        balloon = [CCSprite spriteWithFile:@"graphite.png"];
    //Left side (their messages):
    else
        balloon = [CCSprite spriteWithFile:@"grey.png"];
    size = CGSizeMake(0, max(balloon.contentSize.height,size.height + 15)); //max ensures balloon is not shrunk
    //set size to encompass the chat balloon and the facebook profile picture sprite.
    size = CGSizeMake(CCDirector.sharedDirector.winSize.width, max(size.height, 40) + 6); //6=padding, 40 = fbSprite height
    
    return size;
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
    return numCells;
}


//called when back arrow is pressed in nav bar
-(void) back
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popBack.wav"];
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionSlideInL class] duration:0.25f];
}

- (void)refresh
{
	//Hide keyboard then reload chat
    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
	[message resignFirstResponder];
	[MGWU getMessagesWithFriend:friendID andCallback:@selector(reload:) onTarget:self];
}


- (void)reload:(NSMutableArray*)t
{
	//Update transcript and reload the table view
	transcript = t;
	[self reloadData];
    
	//Scroll to bottom to show newest chats
	if([transcript count] > 0)
	{
        [self scrollToBottom];
	}

}

- (void)send
{
	//Hide keyboard
	[message resignFirstResponder];
	//If text input is not empty, send message up to server and empty text input. Callback will reload chat
	if (message.text && ![message.text isEqualToString:@""])
	{
		[MGWU sendMessage:message.text toFriend:friendID andCallback:@selector(reload:) onTarget:self];
		[message setText:@""];
	}
}

-(void) scrollToBottom
{
    [tableView setContentOffset:ccp(0,0) animated:NO];
}

//makes sure text field follows the chat bar (during sliding transitions and when keyboard popup moves chat toolbar)
-(void) update:(ccTime)delta
{
    //plain english: not during a transition OR (if during a transition) not at the origin -
    //ensures text field is not reset to 0 at the end of the transition - causes a flicker
    if (CCDirector.sharedDirector.runningScene == self.parent || (self.parent.position.x!=0 || self.parent.position.y!=0))
        message.frame = CGRectMake(7+self.parent.position.x,CCDirector.sharedDirector.winSize.height-4-35-toolbar.position.y, 263,35);
    [super update:delta];
}

//Delegate method to hide keyboard when done is pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self send];
	return YES;
}

//Delgate method to animate chat text field to move up with keyboard
- (void)keyboardWillShow:(NSNotification *)notif {
	//Animate view to resize along with keyboard displaying
//	[UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.25];
//        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
	int delta = 216;
	
//    message.center=ccpSub(message.center,ccp(0,delta));
	
    CCMoveBy* moveChatBar = [CCMoveBy actionWithDuration:0.25f position:ccp(0,delta)];
    CCEaseInOut* easeBar = [CCEaseInOut actionWithAction:moveChatBar rate:3];
    
    CCMoveBy* moveTable = [CCMoveBy actionWithDuration:0.25f position:ccp(0,delta)];
    CCEaseInOut* easeTable = [CCEaseInOut actionWithAction:moveTable rate:3];

//	[UIView commitAnimations];
    [toolbar runAction:easeBar];
    [tableView runAction:easeTable];

	//Scroll to bottom of table view
	if([transcript count] > 0)
	{
        [self scrollToBottom];
	}
	
}

//Delgate method to animate chat text field to move down with keyboard
- (void)keyboardWillHide:(NSNotification *)notif {
	//Animate view to resize along with keyboard hiding
	
	int delta = 216;
    
    CCMoveBy* moveChatBar = [CCMoveBy actionWithDuration:0.25 position:ccp(0,-delta)];
    CCEaseInOut* easeBar = [CCEaseInOut actionWithAction:moveChatBar rate:3];
    
    CCMoveBy* moveTable = [CCMoveBy actionWithDuration:0.25f position:ccp(0,-delta)];
    CCEaseInOut* easeTable = [CCEaseInOut actionWithAction:moveTable rate:3];

    [toolbar runAction:easeBar];
    [tableView runAction:easeTable];
}

//called when layer/scene is removed (after transition finishes)
-(void) onExit
{
    //Unregister for alerts
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    //remove text field
    [message removeFromSuperview];
    [self unscheduleUpdate];
    [super onExit];
}

//make text field appear when layer appears (when transition begins)
//this is because the text field is actually added (invisible) when ChatLayer is initialized, but before it's added
-(void) onEnter
{
    message.hidden=NO;
    [super onEnter];
}

@end
