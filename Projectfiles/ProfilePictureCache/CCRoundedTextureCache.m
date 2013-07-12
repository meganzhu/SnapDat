//
//  CCRoundedTextureCache.m
//  Ghost
//
//  Created by BrianC on 1/17/13.
//
//

#import "CCRoundedTextureCache.h"
#import "ImageManipulator.h"

#import "ccMacros.h"
#import "CCGL.h"
#import "CCTextureCache.h"
#import "CCTexture2D.h"
#import "CCTexturePVR.h"
#import "CCConfiguration.h"
#import "CCDirector.h"
#import "ccConfig.h"
#import "ccTypes.h"

#import "CCFileUtils.h"
#import "NSThread+performBlock.h"

@implementation CCRoundedTextureCache

+ (CCRoundedTextureCache *)sharedTextureCache
{
	return (CCRoundedTextureCache*) super.sharedTextureCache;
}



-(CCTexture2D*) addImage: (NSString*) path
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nill");
    
	__block CCTexture2D * tex = nil;
    
	// remove possible -HD suffix to prevent caching the same image twice (issue #1040)
#ifdef __CC_PLATFORM_IOS
	path = [[CCFileUtils sharedFileUtils] removeSuffixFromFile: path];
#endif
    
	dispatch_sync(_dictQueue, ^{
		tex = [_textures objectForKey: path];
	});
    
	if( ! tex ) {
        
		NSString *lowerCase = [path lowercaseString];
        
		// all images are handled by UIKit/AppKit except PVR extension that is handled by cocos2d's handler
        
		if ( [lowerCase hasSuffix:@".pvr"] || [lowerCase hasSuffix:@".pvr.gz"] || [lowerCase hasSuffix:@".pvr.ccz"] )
			tex = [self addPVRImage:path];
        
#ifdef __CC_PLATFORM_IOS
        
		else {
            
			ccResolutionType resolution;
			NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:path resolutionType:&resolution];
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:fullpath];
            image = [ImageManipulator makeRoundCornerImage:image :5 :5];
			tex = [[CCTexture2D alloc] initWithCGImage:image.CGImage resolutionType:resolution];
			[image release];
            
			if( tex ){
				dispatch_sync(_dictQueue, ^{
					[_textures setObject: tex forKey:path];
				});
			}else{
				CCLOG(@"cocos2d: Couldn't add image:%@ in CCTextureCache", path);
			}
            
			// autorelease prevents possible crash in multithreaded environments
			[tex autorelease];
		}
        
        
#elif defined(__CC_PLATFORM_MAC)
		else {
			NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath: path ];
            
			NSData *data = [[NSData alloc] initWithContentsOfFile:fullpath];
			NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithData:data];
			tex = [ [CCTexture2D alloc] initWithCGImage:[image CGImage]];
            
			[data release];
			[image release];
            
			if( tex ){
				dispatch_sync(_dictQueue, ^{
					[textures_ setObject: tex forKey:path];
				});
			}else{
				CCLOG(@"cocos2d: Couldn't add image:%@ in CCTextureCache", path);
			}
            
			// autorelease prevents possible crash in multithreaded environments
			[tex autorelease];
		}
#endif // __CC_PLATFORM_MAC
        
	}
    
	return tex;
}
@end
