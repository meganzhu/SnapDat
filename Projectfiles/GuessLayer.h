//
//  GuessLayer.h
//  pic3
//
//  Created by Megan on 8/6/13.
//  AND THE GUESS LAYER RETURNSSS.
//  Lol remaking this project qq

#import "StyledCCLayer.h"
#import "Data.h"

@interface GuessLayer : StyledCCLayer
{
    Data* data;
    NSArray* prompts;
    NSString* prompt;
    BOOL correct;
}

-(CCScene*) sceneWithSelf;

@end
