//
//  PhotoLayer.h
//  pic3
//
//  Created by Megan Zhu on 7/10/13.
//
//

#import "StyledCCLayer.h"
#import "Data.h"
#import <UIKit/UIKit.h>

@interface PhotoLayer : StyledCCLayer <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIWindow *window;
    Data* data;
    CCControlButton* button;
    UIViewController *vc;
}
-(CCScene*) sceneWithSelf;
-(id) init;
-(void) takePic;
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (NSString*)saveImage: (UIImage*)image;
- (void) toPromptLayer;
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
-(void) back;

@end
