//
//  PopupLayer.h
//  Ghost
//
//  Created by Brian Chu on 1/15/13.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "StyledCCLayer.h"

@protocol PopupDelegate <NSObject>
-(void)dismiss;
@end

@interface PopupLayer : StyledCCLayer
{
	//Labels
	CCLabelTTF* titleLabel;
	CCLabelTTF* messageLabel;
	
	//Delegate to dismiss popup
	id<PopupDelegate> delegate;
}
@property CCLabelTTF *titleLabel, *messageLabel;
@property id<PopupDelegate> delegate;

-(void) rescaleTitleWithString: (NSString*) string;
-(void) rescaleMessageWithString: (NSString*) string;

@end
