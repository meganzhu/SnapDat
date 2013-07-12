//
//  GuessLayer.h
//  pic game
//
//  Created by Megan Zhu on 1/8/13.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//  made from brian chu's ghost template

#import "StyledCCLayer.h"

@interface PromptLayer: StyledCCLayer <UITextFieldDelegate>
{
    NSMutableArray *choices;
}
@property NSMutableArray* choices;

-(CCScene*) sceneWithSelf;
-(void) selected1;
-(void) selected2;
-(void) selected3;
-(void) updateGameWithWord: (NSString*) word;

@end
