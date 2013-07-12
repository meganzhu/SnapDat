//
//  CCControlButtonNoSwallow.m
//  Ghost
//
//  Created by Brian Chu on 1/16/13.
//
//

#import "CCControlButton+NoSwallow.h"

@implementation CCControlButton (NoSwallow)

//OVERRIDES METHOD IN CCControl.m
- (void)onEnter
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    CCTouchDispatcher * dispatcher  = [CCDirector sharedDirector].touchDispatcher;
	[dispatcher addTargetedDelegate:self priority:defaultTouchPriority_ swallowsTouches:NO]; //YES changed to NO
#endif
    
    //HACK:
    //This bypasses calling [CCControlButton onEnter] or [CCControl onEnter] and instead directly calls [CCLayer onEnter];
    void(*onEnterImp)(id,SEL) = [CCLayer instanceMethodForSelector:@selector(onEnter)];
    onEnterImp(self, _cmd);
}

@end
