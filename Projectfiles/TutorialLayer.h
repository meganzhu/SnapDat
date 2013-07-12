//
//  TutorialLayer.h
//  Ghost
//
//  Created by Ashutosh Desai on 1/14/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "StyledCCLayer.h"

@interface TutorialLayer : StyledCCLayer
{
	int index;
	
	NSString *topText;
	NSString *middleText;
	NSString *buttonText;
	int topFontSize;
	int middleFontSize;
}

-(CCScene*) sceneWithSelf;
-(void) next;
-(void) setUpText;
-(void) setUpKeyboard;
-(void) setUpScore;

@end
