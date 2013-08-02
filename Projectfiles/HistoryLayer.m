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
#import "SimpleAudioEngine.h"

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
    if (moveWord) //if not first turn, in which we have no prompt or pic
    {
        CCLabelTTF* word = [CCLabelTTF labelWithString:moveWord fontName:@"Nexa Bold" fontSize:20];
        word.position = ccp(loc.x, loc.y+90);
        [self addChild: word];
        
        if ([move objectForKey:@"pic"])
        {
            UIImage* movePic = [move objectForKey: @"pic"];
            CCSprite* pic = [[CCSprite alloc] initWithCGImage: [movePic CGImage] key:@"pic"];
            pic.scale = 0.3f;
            pic.position = loc;
            [self addChild: pic];
        }
    }

}

-(void) back
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popBack.wav"];
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionFlipX class] duration:0.5f];
}

@end
