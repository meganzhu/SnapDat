//
//  BadgedCCMenuItemSprite.h
//  Ghost
//
//  Created by Brian Chu on 11/14/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "CCMenuItem.h"

@interface BadgedCCMenuItemSprite : CCMenuItemImage
{
    CCSprite* badge;
    CCLabelTTF* label;
}
@property (nonatomic, setter = setBadgeString:) NSString* badgeString;

@end
