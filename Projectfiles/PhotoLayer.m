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

@implementation PhotoLayer
-(CCScene*) sceneWithSelf
{
    CCScene* scene = [[self superclass] scene];
    [scene addChild: self];
    return scene;
}

-(id) init
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
    [self removeAllChildren];
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Delegate is self
    imagePicker.delegate = self;
    
    // Allow editing of image ?
    imagePicker.allowsImageEditing = NO;
    
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
}


@end
