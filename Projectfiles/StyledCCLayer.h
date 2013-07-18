//
//  StyledCCLayer.h
//  Ghost
//
//  Created by Brian Chu on 12/18/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "CCLayer.h"

@class CCControlButton;
@class GameLayer;

@interface StyledCCLayer : CCLayer
{
//properties that are re-declared here are exposed to subclasses
//    __weak CCSprite* bgImage;
    CCSprite* backgroundTopClip;
    CCSprite* titleBar;
    CCMenu* titleBarMenu;
    
    CCLabelTTF* title;
}
@property CCSprite* titleBar;
@property CCLabelTTF* title;
@property GameLayer *gameLayer;

+(id) scene;
+(CCSprite*) bgImage;
-(void) moveBackgroundForward;
-(void) moveBackgroundBack;
-(void) addBackgroundTopClip;
-(void) addNavBarWithTitle: (NSString*) title;
-(void) removeNavBar;
-(void) addBackButton;
-(CCScene*) sceneWithSelf; //a promise that I can return a scene.
- (CCControlButton *)standardButtonWithTitle:(NSString *)titleStr
                                        font:(NSString*)fontName
                                    fontSize:(float)fontSize
                                      target:(id)target
                                    selector:(SEL)selector
                               preferredSize:(CGSize)preferredSize;
- (CCControlButton *)standardButtonWithTitle:(NSString *)titleStr
                                    fontSize:(float)fontSize
                                    selector:(SEL)selector
                               preferredSize:(CGSize)preferredSize;
-(CCMenuItem*) buttonWithTitle:(NSString*)titleString size:(CGSize)size target:(id)target selector:(SEL)selector;

//abstract, must be implemented in every class that has a back button (any class that calls "addBackButton")
-(void)back;

@end
