//
//  DefinitionViewController.h
//  Ghost
//
//  Created by Ashutosh Desai on 12/14/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import <UIKit/UIKit.h>

@interface DefinitionViewController : UIViewController <UIGestureRecognizerDelegate>
{
	NSString *definition;
}

@property UITextView *textView;
@property NSString *definition;

@end
