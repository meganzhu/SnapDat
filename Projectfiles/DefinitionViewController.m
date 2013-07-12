//
//  DefinitionViewController.m
//  Ghost
//
//  Created by Ashutosh Desai on 12/14/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "DefinitionViewController.h"

@interface DefinitionViewController ()

@end

@implementation DefinitionViewController

@synthesize textView, definition;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	//Set text / font for definition
	textView.text = definition;
	textView.font = [UIFont fontWithName:@"Nexa Bold" size:18.0];
	
	//Add swipe gesture recognizer so a downswipe will dismiss view
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																						  action:@selector(dismiss)];
	swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
	swipeRecognizer.delegate = self;
	[self.view addGestureRecognizer:swipeRecognizer];
}

- (void)dismiss
{
	[self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //Touching/swiping the textview will not dismiss the view controller
    return ![touch.view isKindOfClass:[UITextView class]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
