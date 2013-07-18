//
//  PhotoLayer.m
//  pic3
//
//  Created by Megan Zhu on 7/10/13.
//
//

#import "PhotoLayer.h"
#import "CCControlExtension.h"
#import "Data.h"
#import "PromptLayer.h"
#import "CCDirector+PopTransition.h"

@implementation PhotoLayer
-(CCScene*) sceneWithSelf
{
    CCScene* scene = [[self superclass] scene];
    [scene addChild: self];
    return scene;
}

-(id) init //set up view controller and take pic button
{
    data = [Data sharedData];
    if(self = [super init])
    {
        vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        NSString* prompt = [[data.game objectForKey: @"gamedata"] objectForKey: @"promptForMe"];
        button = [self standardButtonWithTitle:[NSString stringWithFormat:@"Something %@", prompt] font:@"Nexa Bold" fontSize:40 target:self selector:@selector(takePic) preferredSize:CGSizeMake(300, 61)];
        button.position = ccp(160,92);
        [self addChild: button];
    }
    return self;
}
-(void) takePic
{
    data = [Data sharedData];
//    [self removeAllChildren];
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary; //sourceTypeCamera on phone.
    
    // Delegate is self
    imagePicker.delegate = self;
    
    // Allow editing of image ?
    imagePicker.allowsImageEditing = YES;
    
    // Show image picker
    [vc presentModalViewController: imagePicker animated:YES];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// After saving image, dismiss camera
	[vc dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    data.myPic = image;
	// Save image
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
//	[picker release];
    
    //after taken pic, go to promptLayer
    StyledCCLayer * promptLayer = [[PromptLayer alloc] init];
    [CCDirector.sharedDirector popScene];
    CCTransitionFlipX* transition = [CCTransitionFlipX transitionWithDuration:0.5f scene:[promptLayer sceneWithSelf]];
    [CCDirector.sharedDirector pushScene:transition];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
	// Unable to save the image
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image to Photo Album."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
	else // All is well
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"Image saved to Photo Album."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    
    
    [alert show];
//[alert release];
}


-(void) back
{
    //pop scene, slide in new scene from the left
    [CCDirector.sharedDirector popSceneWithTransition:[CCTransitionSlideInL class] duration:0.25f];
}

@end
