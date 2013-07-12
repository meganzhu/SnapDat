//
//  StartLayer.m
//  Ghost
//
//  Created by Brian Chu on 10/29/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "StartLayer.h"
#import "InterfaceLayer.h"
#import "CCControlButton.h"
#import "TutorialLayer.h"

@interface StartLayer ()
@end

@implementation StartLayer

-(id) init
{
	if ((self = [super init]))
	{
		inGame=NO;
        CGSize screenSize = CCDirector.sharedDirector.winSize;
        
        //Ghost logo
        CCSprite* ghostLogo = [CCSprite spriteWithFile:@"Logo.png"];
        ghostLogo.anchorPoint = ccp(0.5, 1.0);
        ghostLogo.position = ccp(160, screenSize.height-23);
        [self addChild:ghostLogo];
        
        //Play
        playButton = [self standardButtonWithTitle:@"PLAY" fontSize:40 selector:@selector(play) preferredSize:CGSizeMake(156, 90)];
        playButton.anchorPoint = ccp(0.5, 1.0);
        playButton.position = ccp(ghostLogo.position.x, ghostLogo.position.y - ghostLogo.contentSize.height - 8);
        [self addChild:playButton];
        
        //How to Play
        CCControlButton* howToPlayButton = [self standardButtonWithTitle:@"HOW TO PLAY" fontSize:35 selector:@selector(howToPlay) preferredSize:CGSizeMake(307, 62)];
        howToPlayButton.anchorPoint = playButton.anchorPoint;
        howToPlayButton.position =  ccp(playButton.position.x, playButton.position.y - playButton.contentSize.height - 18);
        [self addChild:howToPlayButton];

        //MoreGames
        moreGamesButton = [self standardButtonWithTitle:@"MORE GAMES" fontSize:35 selector:@selector(moreGames) preferredSize:CGSizeMake(307, 62)];
        moreGamesButton.anchorPoint =  howToPlayButton.anchorPoint;
        moreGamesButton.position = ccp(howToPlayButton.position.x, howToPlayButton.position.y - howToPlayButton.contentSize.height - 12);
        [self addChild:moreGamesButton];

        //If player has not completed the tutorial yet, hide the other buttons, otherwise show them
//        BOOL completedTutorial = [[NSUserDefaults standardUserDefaults] boolForKey:@"completedTutorial"];
//        if (!completedTutorial)
//        {
//            playButton.visible=NO;
//            moreGamesButton.visible=NO;
//        }
//        else
//        {
//            playButton.visible=YES;
//            moreGamesButton.visible=YES;
//        }
        
	}
	return self;
}

-(void)play
{
    //slide in scene from the right
    CCTransitionSlideInR* transition = [CCTransitionSlideInR transitionWithDuration:0.25f scene:[InterfaceLayer scene]];
    [CCDirector.sharedDirector replaceScene:transition];
}

-(void)howToPlay
{

    //slide in scene from the right
    CCTransitionSlideInR* transition = [CCTransitionSlideInR transitionWithDuration:0.25f scene:[TutorialLayer scene]];
    [CCDirector.sharedDirector replaceScene:transition];
}

- (void)moreGames
{
	[MGWU displayCrossPromo];
}

+(id) scene
{
    CCScene *scene = [super scene];
    StartLayer* layer = [StartLayer node];
	[scene addChild: layer];
	return scene;
}


@end
