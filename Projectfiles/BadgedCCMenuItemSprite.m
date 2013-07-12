//
//  BadgedCCMenuItemSprite.m
//  Ghost
//
//  Created by Brian Chu on 11/14/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "BadgedCCMenuItemSprite.h"

@implementation BadgedCCMenuItemSprite
@synthesize badgeString;

//Designated initializer
-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalI selectedSprite:(CCNode<CCRGBAProtocol>*)selectedI disabledSprite:(CCNode<CCRGBAProtocol>*)disabledI block:(void(^)(id sender))block
{
    self = [super initWithNormalSprite:normalI selectedSprite:selectedI disabledSprite:disabledI block:block];
    
    label = [CCLabelTTF labelWithString:@"0" fontName:@"HelveticaNeue-Bold" fontSize:12]; //text (number) in badge
    badge = [CCSprite spriteWithFile:@"UIButtonBarBadge.png"];
    [badge addChild:label];

    badge.position = [self convertToNodeSpace:ccp(22,11)];
    label.position = ccpAdd(badge.anchorPointInPoints, ccp(0,2.5)); //5 is the pixel perfect offset (retina) -> 2.5
    
    return self;
}

//setter method for badge string - remove badge is number is 0
-(void) setBadgeString: (NSString*) string
{
    badgeString=string;
    if (string==nil || [badgeString isEqualToString:@"0"] || [badgeString isEqualToString:@""])
    {
        if (badge.parent != nil)
        {
            [badge removeFromParentAndCleanup:NO];
        }
    }
    else
    {
        label.string = string;
        if (badge.parent==nil)
        {
            [self addChild:badge];
        }
    }
}

//***Overrides original method.
//We override this so that if item.isEnabled==NO AND no disabledImage is set, the disabled image that is displayed is going to be the selected image,
//rather than the default behavior of the normalImage being displayed
-(void) updateImagesVisibility
{
	if( _isEnabled ) {
		[_normalImage setVisible:YES];
		[_selectedImage setVisible:NO];
		[_disabledImage setVisible:NO];
		
	} else {
		if( _disabledImage ) {
			[_normalImage setVisible:NO];
			[_selectedImage setVisible:NO];
			[_disabledImage setVisible:YES];
		} else {
			[_normalImage setVisible:NO]; //override changes here
			[_selectedImage setVisible:YES]; //override changes here
			[_disabledImage setVisible:NO];
		}
	}
}


@end
