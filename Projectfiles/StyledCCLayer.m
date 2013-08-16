//
//  StyledCCLayer.m
//  Ghost
//
//  Created by Brian Chu on 12/18/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "StyledCCLayer.h"
#import "CCControlExtension.h"
#import "CCControlButton+NoSwallow.h"

@implementation StyledCCLayer
@synthesize titleBar,title,gameLayer;

//only a single bgImage will ever be referenced
static __weak CCSprite* bgImage;

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    //add bgImage at the back of the scene
    if (!bgImage || bgImage.parent) //create bgImage if no reference exists or is already added to a parent
        bgImage = [CCSprite spriteWithFile:@"background.png"];
    bgImage.scaleY = CCDirector.sharedDirector.winSize.height / bgImage.contentSize.height;
    bgImage.anchorPoint=ccp(0,0);
    bgImage.position=ccp(0,0);
    
    [scene addChild:bgImage z:-1];
    
	return scene;
}

//getter method
+(CCSprite*) bgImage
{
    return bgImage;
}


-(id) init
{
    self = [super init];
    
    return self;
}

-(void) moveBackgroundForward
{
    [self.parent reorderChild:bgImage z:0];
}

-(void) moveBackgroundBack
{
    [self.parent reorderChild:bgImage z:-1];
}

//image that clips off top of table
-(void) addBackgroundTopClip
{
    backgroundTopClip = [CCSprite spriteWithFile:@"backgroundTopClip.png"];
    backgroundTopClip.anchorPoint=ccp(0,1.0);
    backgroundTopClip.position = ccp(0, CCDirector.sharedDirector.winSize.height);
    [self addChild:backgroundTopClip z:1];
}

//navigation bar at top of screen
-(void) addNavBarWithTitle: (NSString*) titleString
{
    CGSize screenSize = CCDirector.sharedDirector.winSize;
    
    //Top menu Bar
    titleBar = [CCSprite spriteWithFile:@"navigationBar.png"];
    titleBar.scaleX = screenSize.width/titleBar.contentSize.width; //stretch the background
    titleBar.position=ccp(screenSize.width / 2, screenSize.height - 27); //54 is the height of the bar, 27 is half that;
    [self addChild:titleBar z:2];
    
    //Title
    title = [CCLabelTTF labelWithString:titleString fontName:@"ghosty" fontSize:30];
    title.position = ccp(titleBar.position.x, titleBar.position.y-3); //-3 is a tweak to the positioning of the title
    title.color=ccc3(63, 70, 68);;
    
    //Menu
    titleBarMenu = [CCMenu menuWithItems:nil, nil];
    titleBarMenu.position=ccp(0,0);
    [titleBar addChild:titleBarMenu z:1];

    [self addChild:title z:2];
}
-(void) removeNavBar
{
    [self removeChild:titleBar cleanup:YES];
    [self removeChild:title cleanup:YES];
}

//NOTE: any class that calls this method must implement a "back" method. The back method will be called when the button is pressed
-(void) addBackButton
{
    CCMenuItemImage* back = [CCMenuItemImage itemWithNormalImage:@"back.png" selectedImage:nil target:self selector:@selector(back)];
    back.anchorPoint=ccp(0,0.5);
    back.position = ccp(0,27);
    [titleBarMenu addChild:back z:2];
}


//helper constructor method for buttons
- (CCControlButton *)standardButtonWithTitle:(NSString *)titleStr
                                        font:(NSString*)fontName
                                    fontSize:(float)fontSize
                                      target:(id)target
                                    selector:(SEL)selector
                               preferredSize:(CGSize)preferredSize
{ 
    /*
     capInsets are used because we have to stretch the button to fill the text.
     Cap insets allow for certain parts of an image to be stretched while other parts remain intact.
     The main use-case is for a rounded button where you want the corner, rounded edges, and border to remain intact but the center of the button can be stretched
     Ghost uses cap insets to allow the button to maintain slightly faded edges, and the selected button state to maintain an unstretched red border.
     
     To use capInsets here, you specify the portion of the image that is unstretched. A CGRect struct is passed into capInsets.
     The CGRect struct is constructed with CGRectMake(x,y,width,height), where x and y are the coordinates of the upper-left corner of the unstretched portion,
     and width and height specify the width (going to the right) and the height (going down) of the unstretched portion.
     
     Note that UIKit cap insets work differently (different parameters are used in the CGRect struct).
     */
    
    /** Creates and return a button with a default background and title color. */
    CCScale9Sprite *bgButton = [CCScale9Sprite spriteWithFile:@"button.png" capInsets:CGRectMake(11, 11, 126, 95)]; //left, top, width, height (origin, size)
    CCScale9Sprite *bgHighlightedButton = [CCScale9Sprite spriteWithFile:@"button-pressed.png" capInsets:CGRectMake(14, 14, 120, 90)];
    
    //title
    ccColor3B textColor = ccc3(63, 70, 68); //dark grey
    CCLabelTTF *titleLabel= [CCLabelTTF labelWithString:titleStr fontName:fontName fontSize:fontSize];
    titleLabel.color = textColor;
    
    CCControlButton *button = [CCControlButton buttonWithLabel:titleLabel backgroundSprite:bgButton];
    [button setBackgroundSprite:bgHighlightedButton forState:CCControlStateHighlighted];
    [button setTitleColor:textColor forState:CCControlStateHighlighted];
    [button setZoomOnTouchDown:NO]; //button does not resize when pressed
    titleLabel.verticalAlignment = kCCVerticalTextAlignmentCenter;
    
    //Adjustment to label positoning
    button.labelAnchorPoint = ccp(0.5,0.6);
    
    //Add a touch listener that calls the target with the selector for a certain event
    //TouchUpInside - you pressed and released the button with your last touch inside the button
    [button addTarget:target action:selector forControlEvents:CCControlEventTouchUpInside];
    
    if (preferredSize.width != 0 && preferredSize.height!=0)
    {
        [button setPreferedSize:preferredSize];
        button.adjustBackgroundImage=NO;
    }
    
    return button;
}

- (CCControlButton *)standardButtonWithTitle:(NSString *)titleStr
                                 fontSize:(float)fontSize
                                 selector:(SEL)selector
                               preferredSize:(CGSize)preferredSize
{
    //capInsets -> left, top, width, height
    return [self standardButtonWithTitle:titleStr font:@"Nexa Bold" fontSize:fontSize target:self selector:selector preferredSize:preferredSize];
}

- (CCControlButton *)standardButtonWithBackground:(CCScale9Sprite*)backgroundButton andSelectedBackground: (CCScale9Sprite*) backgroundHighlightedButton selector:(SEL) selector
{
    
    CCControlButton *button = [CCControlButton buttonWithBackgroundSprite:backgroundButton];
    button.adjustBackgroundImage=NO;
    [button setBackgroundSprite:backgroundHighlightedButton forState:CCControlStateHighlighted];
    [button setZoomOnTouchDown:NO];
    
    //TouchUpInside - you pressed and released the button with your last touch inside the button
    [button addTarget:self action:selector forControlEvents:CCControlEventTouchUpInside];
    
    return button;
}


//doesn't use cap insets:
-(CCMenuItem*) buttonWithTitle:(NSString*)titleString
                          size:(CGSize)size
                        target:(id)target
                      selector:(SEL)selector
{
    CCSprite* button = [CCSprite spriteWithFile:@"button.png"];
    button.scaleX = size.width / button.contentSize.width;
    button.scaleY = size.height / button.contentSize.height;
    button.anchorPoint=ccp(0.5,0.5);
    
    CCSprite* selectedButton = [CCSprite spriteWithFile:@"button-pressed.png"];
    selectedButton.scaleX = size.width / selectedButton.contentSize.width;
    selectedButton.scaleY = size.height / selectedButton.contentSize.height;
    selectedButton.anchorPoint=button.anchorPoint;
    
    CCMenuItemSprite* buttonItem = [CCMenuItemSprite itemWithNormalSprite:button selectedSprite:selectedButton
                                                                 target:target selector:selector];

    CCLabelTTF* titleLabel = [CCLabelTTF labelWithString:titleString fontName:@"Nexa Bold" fontSize:18];
    titleLabel.position = ccpMult(ccpFromSize(titleLabel.contentSize),0.5);
    [buttonItem addChild: titleLabel];
    
    return buttonItem;
}

//abstract, must be implemented in every class that has a back button (any class that calls "addBackButton")
-(void) back
{}

@end
