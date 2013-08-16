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
#import "GameLayer.h"
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
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"popForward.wav"];
        data = [Data sharedData];
        data.isPrePhotoTesting = FALSE;
        data.inPhoto = TRUE;
        vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];

        NSString* prompt = [NSString stringWithFormat:@"Take a pic of something %@", data.prompt];
        CCLabelTTF *promptLabel = [CCLabelTTF labelWithString:prompt dimensions:CGSizeMake(280, 80) hAlignment:kCCTextAlignmentCenter fontName:@"Nexa Bold" fontSize:25];

        button = [self standardButtonWithTitle:@"Pictime!" font:@"Nexa Bold" fontSize:40 target:self selector:@selector(takePic) preferredSize:CGSizeMake(300, 61)];
        //CHANGE to camera button.
        
        if (data.isPrePhotoTesting == TRUE) //if not ready to take photos, button to go to prompt instead.
        {
            button = [self standardButtonWithTitle:@"JKnophoto" font:@"Nexa Bold" fontSize:40 target:self selector:@selector(toPromptLayer) preferredSize:CGSizeMake(300, 61)];
        }
        promptLabel.position = ccp(160, 380);
        button.position = ccp(160,92);
        
        [self addChild: promptLabel];
        [self addChild: button];
    }
    return self;
}

-(void) takePic
{

    [[SimpleAudioEngine sharedEngine] playEffect:@"popForward.wav"];
//    [self removeAllChildren];
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera; //sourceTypeCamera on phone.
    
    // Delegate is self
    imagePicker.delegate = self;
    
    // Allow editing of image ?
    imagePicker.allowsEditing = NO;
    
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

    //downsize image.
    if (image.size.width > image.size.height) //if landscape, rotate
    {
        image = [[UIImage alloc] initWithCGImage: [image CGImage]
                                           scale: 1.0
                                     orientation: UIImageOrientationLeft];
        
    }
    UIImage* smallImage = [Photo imageWithImage:image scaledToSize: CGSizeMake(640.0f, 960.0f)];
    
	// Save image
    data.myPicPath = [self saveImage: smallImage];
    
    UIImageWriteToSavedPhotosAlbum(smallImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
//	[picker release];
    
    [self toGameLayer];
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

- (void) toGameLayer
{
    [super.gameLayer updateGameWithPic];
    
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
