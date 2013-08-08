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
        //CHANGE: moves right now is really inaccurate.
        data = [Data sharedData];
        moves = [data.game objectForKey: @"moves"];
        [self addNavBarWithTitle: @"History"];
        [self addBackButton];
        locy = 370;
        locx = 160;
        moveNumber = [data.game objectForKey:@"movecount"];
        for (int i = [moves count] -1; i >=0; i--, moveNumber--)
        {
            
            [MGWU getFileWithExtension:@"jpg" forGame:[data.game objectForKey:@"gameid"] andMove:moveNumber withCallback:@selector(displayPicWithPath:) onTarget:self];
            locy -= 140;
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
        


    }

}

-(void) displayWithPicPath: (NSString*) picPath
{
    CCSprite* pic = [[CCSprite alloc] initWithCGImage: [movePic CGImage] key:@"pic"];
    pic.scale = 0.3f;
    pic.position = loc;
    [self addChild: pic];
}
-(void) back
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"popBack.wav"];
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionFlipX class] duration:0.5f];
}

@end
