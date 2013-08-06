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
#import "SimpleAudioEngine.h"

@implementation PhotoLayer
-(CCScene*) sceneWithSelf
{
    CCScene* scene = [[self superclass] scene];
    [scene addChild: self];
    return scene;
}

-(id) init //set up view controller and take pic button
{    
    if(self = [super init])
    {
        data = [Data sharedData];
        data.isPrePhotoTesting = FALSE;
        vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        NSString* word = [[data.game objectForKey: @"gamedata"] objectForKey: @"promptForMe"];
        NSString* prompt = [NSString stringWithFormat:@"%@ sent you", data.opponentName];
        CCLabelTTF *promptLabel = [CCLabelTTF labelWithString:prompt dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:25];
        CCLabelTTF *wordLabel = [CCLabelTTF labelWithString: word dimensions: CGSizeMake(280, 80) hAlignment: kCCTextAlignmentCenter fontName: @"Nexa Bold" fontSize:40];
        button = [self standardButtonWithTitle:[NSString stringWithFormat:@"Take a pic!", prompt] font:@"Nexa Bold" fontSize:40 target:self selector:@selector(takePic) preferredSize:CGSizeMake(300, 61)];

        
        if (data.isPrePhotoTesting == TRUE) //if not ready to take photos, button to go to prompt instead.
        {
            button = [self standardButtonWithTitle:@"JKnophoto" font:@"Nexa Bold" fontSize:40 target:self selector:@selector(toPromptLayer) preferredSize:CGSizeMake(300, 61)];
        }
        promptLabel.position = ccp(160, 380);
        wordLabel.position = ccp(160, 330);
        button.position = ccp(160,92);
        
        [self addChild: promptLabel];
        [self addChild: wordLabel];
        [self addChild: button];
    }
    return self;
}

-(void) takePic
{

//    [self removeAllChildren];
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera; //sourceTypeCamera on phone.
    
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

	// Save image
    data.myPicPath = [self saveImage: image];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
//	[picker release];
    
    [self toPromptLayer];
}

- (NSString*)saveImage: (UIImage*)image
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"test.png" ];
        NSData* jpeg = UIImageJPEGRepresentation(image, 0.5);
        [jpeg writeToFile:path atomically:YES];
        return path;
    }
    return nil;
}

- (void) toPromptLayer
{
    StyledCCLayer * promptLayer = [[PromptLayer alloc] init];
    promptLayer.gameLayer = self.gameLayer;
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
