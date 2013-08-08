//
//  HistoryLayer.h
//  pic3
//
//  Created by user on 7/17/13.
//
//

#import "Data.h"
#import "StyledCCLayer.h"

@interface HistoryLayer : StyledCCLayer
{
    Data* data;
    NSArray* moves;
    int moveNumber;
    int locx;
    int locy;
}

-(CCScene*) sceneWithSelf;

@end
