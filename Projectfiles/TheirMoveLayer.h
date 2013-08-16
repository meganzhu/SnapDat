//
//  TheirMoveLayer.h
//  pic3
//
//  Created by user on 8/15/13.
//
//

#import "StyledCCLayer.h"
#import "Photo.h"

@interface TheirMoveLayer : StyledCCLayer

{
    Photo* theirPhoto;
    CCControlButton* next;
    Data* data;
    int picx;
    int picy;
    float picScale;
    
    
}
-(CCScene*) sceneWithSelf;
-(id) init;
-(void) displayPic: (NSString*) path;
@end
