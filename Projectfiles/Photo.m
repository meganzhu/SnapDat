//
//  Photo.m
//  pic3
//
//  Created by user on 8/13/13.
//
//

#import "Photo.h"

@implementation Photo

-(id) initWithPath:(NSString*) path andPos:(CGPoint) pos andScale: (float) scale
{
    //get raw, fullsized image (640x960) or (960x640)
    UIImage* image = [Photo loadImageAtPath: path];
    
    //resize image to scaling

    CGSize oldSize = CGSizeMake(640, 960);
    UIImage* resizedImage = [Photo imageWithImage: image scaledToSize: [Photo scaleSize: oldSize byMultiplier:0.5*scale]];
    
    //init self as sprite with resized image
    self = [super initWithCGImage:[resizedImage CGImage] key:nil];
    
    if (self)
    {
        self.position = pos;
        myPos = pos;
        myScale = scale;
        [self scheduleUpdate];
    }
    return self;
}

+ (UIImage*)loadImageAtPath: (NSString*)path
{
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(CGSize) scaleSize: (CGSize) retinaSize byMultiplier: (float) multiplier
{
    return CGSizeMake(retinaSize.width * multiplier, retinaSize.height * multiplier);
}

-(void) update:(ccTime)delta
{
    KKInput* input = [KKInput sharedInput];
    if ([input isAnyTouchOnNode:self touchPhase:KKTouchPhaseBegan])
    {
        if (!inFSPic)
        {
            self.position = ccp(160, 240);
            [self setScaleX: 320/self.contentSize.width];
            [self setScaleY: 480/self.contentSize.height];
            inFSPic = TRUE;
        }
        else //showing pic FullScreen
        {
            self.position = myPos;
            [self setScaleX: 1];
            [self setScaleY: 1];
            inFSPic = FALSE;
        }
    }
}
@end
