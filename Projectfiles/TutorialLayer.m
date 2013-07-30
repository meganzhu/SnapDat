//
//  TutorialLayer.m
//  Ghost
//
//  Created by Ashutosh Desai on 1/14/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "TutorialLayer.h"
#import "StartLayer.h"
#import "CCControlExtension.h"
#import "SimpleAudioEngine.h"

@implementation TutorialLayer

-(id) init
{
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"popForward.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"popBack.wav"];
    
	//Log event that the tutorial was started (step 0)
	[MGWU logEvent:@"tutorial_step" withParams:@{@"step":[NSNumber numberWithInt:0]}];
	return [self initWithIndex:1];
}

-(id) initWithIndex:(int)i
{
	if ((self = [super init]))
	{
		//Set up tutorial scene based on step number
		index = i;
		
		topText = @"";
		middleText = @"";
		topFontSize = 25;
		middleFontSize = 25;
		
		switch (index) {
			case 1:
				topText = @"";
				middleText = @"Challenge from n00bhelper!";
				buttonText = @"Let's Go!!";
				topFontSize = 30;
				break;
			case 2:
				topText = @"n00bhelper sent you: BADASS";
				middleText = @"Take a pic of something BADASS!!";
				buttonText = @"Pic time!";
				break;
			case 3:
				topText = @"Niiice!";
				middleText = @"";
				buttonText = @"SEND";
				break;
			case 4:
				topText = @"";
				middleText = @"";
				buttonText = @"";
				break;
			case 5:
				topText = @"Press Refresh";
				middleText = @"";
				buttonText = @"";
				middleFontSize = 18;
				break;
			case 6:
                topText = @"n00bhelper sent:";
				middleText = @"";
				buttonText = @"Cuute!";
				break;
			case 7:
                topText = @"Thats it!";
				middleText = @"You finished the tutorial.";
				buttonText = @"MAIN MENU";
				break;
			default:
				break;
		}
		
        switch (index){
            case 1:
            case 2:
            case 7:
                [self setUpText];
                break;
            case 4:
                [self setUpPrompts];
                break;
            case 5:
                [self setUpRefresh];
                break;
            case 3:
            case 6:
                [self setUpDisplayPhoto];
                break;
        }
//		switch (index) {
//			case 1:
//			case 5:
//			case 6:
//			case 7:
//			case 10:
//			case 11:
//			case 13:
//				[self setUpText];
//				break;
//			case 2:
//			case 3:
//			case 4:
//			case 8:
//			case 9:
//				[self setUpKeyboard];
//				break;
//			case 12:
//				[self setUpScore];
//				break;
//			default:
//				break;
//		}
	}
	
	return self;
}

-(void)setUpText
{
	//Set up tutorial scene that is simply text
	int screenHeight = CCDirector.sharedDirector.winSize.height;

	CCLabelTTF *top = [CCLabelTTF labelWithString:topText dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:topFontSize];
	CCLabelTTF *middle = [CCLabelTTF labelWithString:middleText dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:middleFontSize];
	CCControlButton* next = [self standardButtonWithTitle:buttonText font:@"Nexa Bold" fontSize:25 target:self selector:@selector(next) preferredSize:CGSizeMake(200, 70)];
	
	top.position = ccp(160,93);
    middle.position = ccp(160,215);
	next.position = ccp(160,365);
	
	top.position = ccp(top.position.x, screenHeight - top.position.y);
	middle.position = ccp(middle.position.x, screenHeight - middle.position.y);
	next.position = ccp(next.position.x, screenHeight - next.position.y);
	
	[self addChild:top];
    [self addChild:middle];
	[self addChild:next];
}

-(void) setUpPhoto
{
    
}

-(void) setUpPrompts
{
    CCLabelTTF *title1 = [CCLabelTTF labelWithString:@"Now choose a word" fontName:@"Nexa Bold" fontSize:30.0f];
    CCLabelTTF *title2 = [CCLabelTTF labelWithString:@"for n00bhelper" fontName:@"Nexa Bold" fontSize:30.0f];
    CCControlButton* word1 = [self standardButtonWithTitle:@"Awkward" font:@"Nexa Bold" fontSize:25 target:self selector:@selector(doNothing) preferredSize:CGSizeMake(200, 70)];
    CCControlButton* word2 = [self standardButtonWithTitle:@"Epic Fail" font:@"Nexa Bold" fontSize:25 target:self selector:@selector(doNothing) preferredSize:CGSizeMake(200, 70)];
    CCControlButton* word3 = [self standardButtonWithTitle:@"Adorable" font:@"Nexa Bold" fontSize:25 target:self selector:@selector(next) preferredSize:CGSizeMake(200, 70)];
    
    title1.position = ccp(160, 400);
    title2.position = ccp(160, 370);
    word1.position = ccp(160, 280);
    word2.position = ccp(160, 220);
    word3.position = ccp(160, 160);
    
    word1.opacity = 51;
    word2.opacity = 51;
    
    [self addChild: title1];
    [self addChild: title2];
    [self addChild: word1];
    [self addChild: word2];
    [self addChild: word3];

}

-(void) setUpRefresh
{
    int screenHeight = CCDirector.sharedDirector.winSize.height;
    
    CCLabelTTF *top = [CCLabelTTF labelWithString:topText dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:topFontSize];
    CCControlButton* re = [self standardButtonWithTitle:@"REFRESH" font:@"Nexa Bold" fontSize:30 target:self selector:@selector(next) preferredSize:CGSizeMake(300, 61)];
    CCControlButton* moreGames = [self standardButtonWithTitle:@"MORE GAMES" font:@"Nexa Bold" fontSize:20 target:self selector:@selector(doNothing) preferredSize:CGSizeMake(173, 57)];
    CCControlButton* history = [self standardButtonWithTitle:@"HISTORY" font:@"Nexa Bold" fontSize:30 target:self selector:@selector(doNothing) preferredSize:CGSizeMake(300, 61)];
 
    top.position = ccp(160,93);
	re.position = ccp(160,130);
	moreGames.position = ccp(160,400);
    history.position = ccp(160, 350);
    
    top.position = ccp(top.position.x, screenHeight - top.position.y);
	re.position = ccp(re.position.x, screenHeight - re.position.y);
	moreGames.position = ccp(moreGames.position.x, screenHeight - moreGames.position.y);
    history.position = ccp(history.position.x, screenHeight - history.position.y);
    
    moreGames.opacity = 51;
    history.opacity = 51;
    
    [self addChild: top];
    [self addChild:re];
    [self addChild:moreGames];
    [self addChild:history];

}

-(void) setUpDisplayPhoto
{
    int screenHeight = CCDirector.sharedDirector.winSize.height;
    
    CCLabelTTF *top = [CCLabelTTF labelWithString:topText dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:topFontSize];
    CCSprite* pic;
    CCLabelTTF* theirPrompt;
    CCControlButton* next = [self standardButtonWithTitle:buttonText font:@"Nexa Bold" fontSize:25 target:self selector:@selector(next) preferredSize:CGSizeMake(200, 70)];

    if (index == 3)
    {
        pic = nil;
        theirPrompt = [CCLabelTTF labelWithString:@"Badass" fontName:@"Nexa Bold" fontSize:20];
    }
    else
    {
        pic = [CCSprite spriteWithFile: @"CuteGecko.png"];
        pic.scale = 0.7;
        pic.position = ccp(160, 240);
        [self addChild: pic];
        
        theirPrompt = [CCLabelTTF labelWithString:@"Adorable" fontName:@"Nexa Bold" fontSize:20];

    }
    next.position = ccp(160,430);
    top.position = ccp(160,93);
    theirPrompt.position = ccp(160, 380);
    
    top.position = ccp(top.position.x, screenHeight - top.position.y);
	next.position = ccp(next.position.x, screenHeight - next.position.y);
    
    [self addChild: top];
    [self addChild: theirPrompt];
    [self addChild: next];

}
//-(void)setUpKeyboard
//{
//	//Set up tutorial scene that simulates game
//	int screenHeight = CCDirector.sharedDirector.winSize.height;
//	
//	CCLabelTTF *top = [CCLabelTTF labelWithString:topText dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:topFontSize];
//    CCLabelTTF *middle = [CCLabelTTF labelWithString:middleText fontName:@"ghosty" fontSize:40];
//    CCControlButton *challenge = [self standardButtonWithTitle:@"CHALLENGE" font:@"Nexa Bold" fontSize:40 target:self selector:@selector(next) preferredSize:CGSizeMake(280, 66)];
//
//	CCSprite *keyboard = [CCSprite spriteWithFile:@"Keyboard.png"];
//	keyboard.opacity = 51;
//    
//    top.position = ccp(160,63);
//    middle.position = ccp(160,148);
//    challenge.position = ccp(160,214);
//	keyboard.position = ccp(160, keyboard.boundingBox.size.height/2);
//    
//    top.position = ccp(top.position.x, screenHeight - top.position.y);
//	middle.position = ccp(middle.position.x, screenHeight - middle.position.y);
//	challenge.position = ccp(challenge.position.x, screenHeight - challenge.position.y);
//    
//    [self addChild:top];
//    [self addChild:middle];
//    [self addChild:challenge];
//	[self addChild:keyboard];
//	
//	if (buttonText != @"CHALLENGE")
//	{
//		challenge.opacity = 51;
//		challenge.enabled = NO;
//		
//		CCControlButton *key;
//		if (buttonText == @"T")
//		{
//			challenge.visible = NO;
//			key = [CCControlButton buttonWithBackgroundSprite:[CCScale9Sprite spriteWithFile:@"T.png"]];
//			key.position = ccp(144, 185);
//		}
//		else if (buttonText == @"A")
//		{
//			key = [CCControlButton buttonWithBackgroundSprite:[CCScale9Sprite spriteWithFile:@"A.png"]];
//			key.position = ccp(32, 131);
//		}
//		else if (buttonText == @"Q")
//		{
//			key = [CCControlButton buttonWithBackgroundSprite:[CCScale9Sprite spriteWithFile:@"Q.png"]];
//			key.position = ccp(16, 185);
//		}
//		
//		[key setAdjustBackgroundImage:NO];
//		[key addTarget:self action:@selector(next) forControlEvents:CCControlEventTouchUpInside];
//		[self addChild:key];
//	}
//}

//-(void)setUpScore
//{
//	//Set up tutorial scene that shows score
//	int screenHeight = CCDirector.sharedDirector.winSize.height;
//	
//	CCLabelTTF *top = [CCLabelTTF labelWithString:topText dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:topFontSize];
//	CCLabelTTF *you = [CCLabelTTF labelWithString:@"You" fontName:@"Nexa Bold" fontSize:18];
//	CCLabelTTF *opp = [CCLabelTTF labelWithString:@"Opponent" fontName:@"Nexa Bold" fontSize:18];
//	CCSprite *youAv = [CCSprite spriteWithFile:@"WhiteGhost.png"];
//	CCLabelTTF *vs = [CCLabelTTF labelWithString:@"VS" fontName:@"Nexa Bold" fontSize:40];
//	CCSprite *oppAv = [CCSprite spriteWithFile:@"RedGhost.png"];
//	CCLabelTTF *youScore = [CCLabelTTF labelWithString:@">>>>>" fontName:@"ghosty" fontSize:20];
//	CCLabelTTF *oppScore = [CCLabelTTF labelWithString:@"GH>>>" fontName:@"ghosty" fontSize:20];
//	
//	CCControlButton* next = [self standardButtonWithTitle:buttonText font:@"Nexa Bold" fontSize:25 target:self selector:@selector(next) preferredSize:CGSizeMake(200, 70)];
//	
//	top.position = ccp(160,63);
//	you.position = ccp(35, 150);
//	opp.position = ccp(260, 150);
//	youAv.position = ccp(57, 204);
//	vs.position = ccp(160, 216);
//	oppAv.position = ccp(264, 204);
//	youScore.position = ccp(58, 266);
//	oppScore.position = ccp(264, 266);
//	next.position = ccp(160,365);
//	
//	top.position = ccp(top.position.x, screenHeight - top.position.y);
//	you.position = ccp(you.position.x, screenHeight - you.position.y);
//	opp.position = ccp(opp.position.x, screenHeight - opp.position.y);
//	youAv.position = ccp(youAv.position.x, screenHeight - youAv.position.y);
//	vs.position = ccp(vs.position.x, screenHeight - vs.position.y);
//	oppAv.position = ccp(oppAv.position.x, screenHeight - oppAv.position.y);
//	youScore.position = ccp(youScore.position.x, screenHeight - youScore.position.y);
//	oppScore.position = ccp(oppScore.position.x, screenHeight - oppScore.position.y);
//	next.position = ccp(next.position.x, screenHeight - next.position.y);
//	
//	[self addChild:top];
//	[self addChild:you];
//	[self addChild:opp];
//	[self addChild:youAv];
//	[self addChild:vs];
//	[self addChild:oppAv];
//	[self addChild:youScore];
//	[self addChild:oppScore];
//	[self addChild:next];
//}

-(void) doNothing
{
    //I am doing nothing.
    //oman theres gotta be a more elegant approach to this.
}

-(void)next
{
	//Log event for each tutorial step completed
    [MGWU logEvent:@"tutorial_step" withParams:@{@"step":[NSNumber numberWithInt:index]}];
	if (index == 7)
	{ 
		//Save that the tutorial was completed to NSUserDefaults
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"completedTutorial"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
        [[SimpleAudioEngine sharedEngine] playEffect:@"popBack.wav"];
		CCTransitionSlideInL* transition = [CCTransitionSlideInL transitionWithDuration:0.25f scene:[StartLayer scene]];
		[CCDirector.sharedDirector pushScene:transition];
	}
	else
	{
        [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
		TutorialLayer *layer = [[TutorialLayer alloc] initWithIndex:index+1];
		CCTransitionSlideInR* transition = [CCTransitionSlideInR transitionWithDuration:0.25f scene:[layer sceneWithSelf]];
		[CCDirector.sharedDirector pushScene:transition];
	}
	
}

+(id) scene
{
    CCScene *scene = [super scene];
    TutorialLayer* layer = [TutorialLayer node];
	[scene addChild: layer];
	return scene;
}

-(CCScene*) sceneWithSelf
{
    CCScene *scene = [[self superclass] scene];
	[scene addChild: self];
	return scene;
}

@end
