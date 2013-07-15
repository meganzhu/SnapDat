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


@end
