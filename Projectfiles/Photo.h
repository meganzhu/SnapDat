//
//  Photo.h
//  pic3
//
//  Created by user on 8/13/13.
//
//

#import "kobold2d.h"
#import <Foundation/Foundation.h>
#import "Data.h"
#import <UIKit/UIKit.h>

@interface Photo : CCSprite
{
    CGPoint myPos;
    float myScale;
    BOOL inFSPic; //fullscreen pic
}

-(id) initWithPath:(NSString*) path andPos:(CGPoint) pos andScale: (float) scale;
-(void) setImage: (NSString*) imagePath;
-(void) displayImage: (NSString*) imagePath withSize: (CGSize) imageSize;
-(void) setNames;
+(UIImage*) loadImageAtPath: (NSString*) path;
+(UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(CGSize) scaleSize: (CGSize) retinaSize byMultiplier: (float) multiplier;
+(BOOL) isRetina;
-(void) update: (ccTime) delta;
@end
