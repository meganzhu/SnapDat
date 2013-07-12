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

@implementation TutorialLayer

-(id) init
{
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
				topText = @"Welcome to Ghost!";
				middleText = @"In Ghost, players take turns picking letters";
				buttonText = @"Let's Play";
				topFontSize = 30;
				break;
			case 2:
				topText = @"Pick a letter to begin the game";
				middleText = @">";
				buttonText = @"T";
				break;
			case 3:
				topText = @"Your opponent picked H, pick a letter to continue the word";
				middleText = @"T H >";
				buttonText = @"A";
				break;
			case 4:
				topText = @"Your opponent picked T and spelled THAT, tap challenge";
				middleText = @"T H A T >";
				buttonText = @"CHALLENGE";
				break;
			case 5:
				topText = @"You won the round!";
				middleText = @"If you think your opponent has completed a word, you can tap challenge and win the round";
				buttonText = @"Ok";
				middleFontSize = 18;
				break;
			case 6:
				middleText = @"But only if the word is longer than 3 letters";
				buttonText = @"Cool";
				break;
			case 7:
				middleText = @"And if you're wrong, you lose the round";
				buttonText = @"Uh-Oh";
				break;
			case 8:
				topText = @"Let's play again, pick a letter";
				middleText = @">";
				buttonText = @"Q";
				break;
			case 9:
				topText = @"Your opponent picked Q, no words begin with QQ, tap challenge";
				middleText = @"Q Q >";
				buttonText = @"CHALLENGE";
				break;
			case 10:
				topText = @"You won the round!";
				middleText = @"If you think no words begin with the given letters, you can tap challenge and win the round";
				buttonText = @"I See";
				middleFontSize = 18;
				break;
			case 11:
				middleText = @"But if you're wrong, you lose the round";
				buttonText = @"Hmm...";
				break;
			case 12:
				topText = @"When you lose a round, you gain a letter below your avatar. Your opponent has gained two letters";
				buttonText = @"Got It";
				topFontSize = 18;
				break;
			case 13:
				topText = @"";
				middleText = @"First player to spell GHOST (by losing 5 rounds) loses the game";
				buttonText = @"Ok Let's Play!";
				break;
			default:
				break;
		}
		
		switch (index) {
			case 1:
			case 5:
			case 6:
			case 7:
			case 10:
			case 11:
			case 13:
				[self setUpText];
				break;
			case 2:
			case 3:
			case 4:
			case 8:
			case 9:
				[self setUpKeyboard];
				break;
			case 12:
				[self setUpScore];
				break;
			default:
				break;
		}
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

-(void)setUpKeyboard
{
	//Set up tutorial scene that simulates game
	int screenHeight = CCDirector.sharedDirector.winSize.height;
	
	CCLabelTTF *top = [CCLabelTTF labelWithString:topText dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:topFontSize];
    CCLabelTTF *middle = [CCLabelTTF labelWithString:middleText fontName:@"ghosty" fontSize:40];
    CCControlButton *challenge = [self standardButtonWithTitle:@"CHALLENGE" font:@"Nexa Bold" fontSize:40 target:self selector:@selector(next) preferredSize:CGSizeMake(280, 66)];
	
	CCSprite *keyboard = [CCSprite spriteWithFile:@"Keyboard.png"];
	keyboard.opacity = 51;
    
    top.position = ccp(160,63);
    middle.position = ccp(160,148);
    challenge.position = ccp(160,214);
	keyboard.position = ccp(160, keyboard.boundingBox.size.height/2);
    
    top.position = ccp(top.position.x, screenHeight - top.position.y);
	middle.position = ccp(middle.position.x, screenHeight - middle.position.y);
	challenge.position = ccp(challenge.position.x, screenHeight - challenge.position.y);
    
    [self addChild:top];
    [self addChild:middle];
    [self addChild:challenge];
	[self addChild:keyboard];
	
	if (buttonText != @"CHALLENGE")
	{
		challenge.opacity = 51;
		challenge.enabled = NO;
		
		CCControlButton *key;
		if (buttonText == @"T")
		{
			challenge.visible = NO;
			key = [CCControlButton buttonWithBackgroundSprite:[CCScale9Sprite spriteWithFile:@"T.png"]];
			key.position = ccp(144, 185);
		}
		else if (buttonText == @"A")
		{
			key = [CCControlButton buttonWithBackgroundSprite:[CCScale9Sprite spriteWithFile:@"A.png"]];
			key.position = ccp(32, 131);
		}
		else if (buttonText == @"Q")
		{
			key = [CCControlButton buttonWithBackgroundSprite:[CCScale9Sprite spriteWithFile:@"Q.png"]];
			key.position = ccp(16, 185);
		}
		
		[key setAdjustBackgroundImage:NO];
		[key addTarget:self action:@selector(next) forControlEvents:CCControlEventTouchUpInside];
		[self addChild:key];
	}
}

-(void)setUpScore
{
	//Set up tutorial scene that shows score
	int screenHeight = CCDirector.sharedDirector.winSize.height;
	
	CCLabelTTF *top = [CCLabelTTF labelWithString:topText dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:topFontSize];
	CCLabelTTF *you = [CCLabelTTF labelWithString:@"You" fontName:@"Nexa Bold" fontSize:18];
	CCLabelTTF *opp = [CCLabelTTF labelWithString:@"Opponent" fontName:@"Nexa Bold" fontSize:18];
	CCSprite *youAv = [CCSprite spriteWithFile:@"WhiteGhost.png"];
	CCLabelTTF *vs = [CCLabelTTF labelWithString:@"VS" fontName:@"Nexa Bold" fontSize:40];
	CCSprite *oppAv = [CCSprite spriteWithFile:@"RedGhost.png"];
	CCLabelTTF *youScore = [CCLabelTTF labelWithString:@">>>>>" fontName:@"ghosty" fontSize:20];
	CCLabelTTF *oppScore = [CCLabelTTF labelWithString:@"GH>>>" fontName:@"ghosty" fontSize:20];
	
	CCControlButton* next = [self standardButtonWithTitle:buttonText font:@"Nexa Bold" fontSize:25 target:self selector:@selector(next) preferredSize:CGSizeMake(200, 70)];
	
	top.position = ccp(160,63);
	you.position = ccp(35, 150);
	opp.position = ccp(260, 150);
	youAv.position = ccp(57, 204);
	vs.position = ccp(160, 216);
	oppAv.position = ccp(264, 204);
	youScore.position = ccp(58, 266);
	oppScore.position = ccp(264, 266);
	next.position = ccp(160,365);
	
	top.position = ccp(top.position.x, screenHeight - top.position.y);
	you.position = ccp(you.position.x, screenHeight - you.position.y);
	opp.position = ccp(opp.position.x, screenHeight - opp.position.y);
	youAv.position = ccp(youAv.position.x, screenHeight - youAv.position.y);
	vs.position = ccp(vs.position.x, screenHeight - vs.position.y);
	oppAv.position = ccp(oppAv.position.x, screenHeight - oppAv.position.y);
	youScore.position = ccp(youScore.position.x, screenHeight - youScore.position.y);
	oppScore.position = ccp(oppScore.position.x, screenHeight - oppScore.position.y);
	next.position = ccp(next.position.x, screenHeight - next.position.y);
	
	[self addChild:top];
	[self addChild:you];
	[self addChild:opp];
	[self addChild:youAv];
	[self addChild:vs];
	[self addChild:oppAv];
	[self addChild:youScore];
	[self addChild:oppScore];
	[self addChild:next];
}

-(void)next
{
	//Log event for each tutorial step completed
    [MGWU logEvent:@"tutorial_step" withParams:@{@"step":[NSNumber numberWithInt:index]}];
	if (index == 13)
	{
		//Save that the tutorial was completed to NSUserDefaults
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"completedTutorial"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		CCTransitionSlideInL* transition = [CCTransitionSlideInL transitionWithDuration:0.25f scene:[StartLayer scene]];
		[CCDirector.sharedDirector pushScene:transition];
	}
	else
	{
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
