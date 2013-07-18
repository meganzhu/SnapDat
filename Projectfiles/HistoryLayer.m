//
//  HistoryLayer.m
//  pic3
//
//  Created by user on 7/17/13.
//
//

#import "HistoryLayer.h"
#import "CGPointExtension.h"
#import "CCDirector+PopTransition.h"

@implementation HistoryLayer

-(CCScene*) sceneWithSelf
{
    CCScene* scene = [[self superclass] scene];
    [scene addChild: self];
    return scene;
}

-(id) init
{
    if(self = [super init])
    {
        data = [Data sharedData];
        moves = [data.game objectForKey: @"moves"];
        [self addNavBarWithTitle: @"History"];
        [self addBackButton];
        float y = 370;
        for (int i = [moves count] -1; i >=0; i--)
        {
            [self displayMove: moves[i] at: CGPointMake(160, y)];
            y -= 140;
        }
    }
    return self;
}

-(void) displayMove: (NSDictionary*) move at: (CGPoint) loc
{
    NSString* moveWord = [move objectForKey: @"prompt"];
    if (![moveWord isEqual: @""]) //if not first turn, in which we have no prompt or pic
    {
        CCLabelTTF* word = [CCLabelTTF labelWithString:moveWord fontName:@"Nexa Bold" fontSize:20];
        word.position = ccp(loc.x, loc.y+90);
        [self addChild: word];UIImage* movePic = [move objectForKey: @"pic"];
        
        CCSprite* pic = [[CCSprite alloc] initWithCGImage: [movePic CGImage] key:@"pic"];
        pic.scale = 0.3f;
        pic.position = loc;
        [self addChild: pic];
    }

}

-(void) back
{
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionSlideInL class] duration:0.25f];
}

@end
