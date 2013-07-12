//
//  CCControlButtonNoSwallow.h
//  Ghost
//
//  Created by Brian Chu on 1/16/13.
//
//

#import "CCControlButton.h"

@interface CCControlButton (NoSwallow)

//OVERRIDES METHOD IN CCControl.m
- (void)onEnter;
@end
