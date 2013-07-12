//
//  PopupLayer.m
//  Ghost
//
//  Created by Brian Chu on 1/15/13.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "PopupLayer.h"
#import "CCControlButton.h"

@implementation PopupLayer
@synthesize titleLabel, messageLabel, delegate;

- (id) init
{
    self = [super init];
    
    //slightly transparent black background
    CCLayerColor* background = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 179)]; //179 = 70% opacity (0.7 ~= 179/255)
    [self addChild:background];
    
    //popup graphic
    CCSprite* popup = [CCSprite spriteWithFile:@"Popup.png"];
    popup.position = ccpMult(ccpFromSize(CCDirector.sharedDirector.winSize),0.5); //screen center
    [self addChild:popup];
    
    float popupContentHeight = popup.contentSize.height+20; //20 accounts for gap between ImageView and parent view top positions
    
    titleLabel = [CCLabelTTF labelWithString:@"" fontName:@"Nexa Bold" fontSize:25];
    titleLabel.position = ccp(160,popupContentHeight-60);
    [popup addChild:titleLabel];
    
    messageLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter lineBreakMode:kCCLineBreakModeWordWrap fontName:@"Nexa Bold" fontSize:18];
    messageLabel.position = ccp(160,popupContentHeight-102);
    [popup addChild:messageLabel];
    
    CCControlButton* button = [self standardButtonWithTitle:@"OK" font:@"Nexa Bold" fontSize:20 target:self selector:@selector(dismiss:)
                                              preferredSize:CGSizeMake(147, 46)];
    button.position = ccp(160,popupContentHeight-150);
    [popup addChild:button];
    
    return self;
}

-(void) rescaleTitleWithString: (NSString*) string
{
    titleLabel.string = string;
    
    //make sure title doesn't spill off popup
    if (titleLabel.contentSize.width > 246)
        titleLabel.scale = 246 / titleLabel.contentSize.width;
}

-(void) rescaleMessageWithString: (NSString*) string
{
    //constrain message to a set width
    CGSize messageSize = [string sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(246, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    messageLabel.dimensions=messageSize;
    messageLabel.string = string;
    
    //make sure message doesn't spill off popup
    if (messageLabel.contentSize.width > 246)
        messageLabel.scale = 246 / messageLabel.contentSize.height;
    if (messageLabel.contentSize.height > 60)
        messageLabel.scale = 60 / messageLabel.contentSize.height;
    
}

- (void) dismiss:(id)sender
{
	[delegate dismiss];
}

@end
