//
//  ProfilePictureCacheCocos.m
//  Ghost
//
//  Created by Brian Chu on 12/6/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "ProfilePictureCacheCocos.h"
#import "ImageManipulator.h"
#import "CCRoundedTextureCache.h"
#import "SWTableView.h"
#import "SWTableViewCell.h"

@implementation ProfilePictureCacheCocos


+(void)setProfilePicture:(NSString *)u forSprite: (CCSprite*)sprite tableView: (SWTableView*) tableView index:(NSUInteger)idx
{
	ProfilePictureCacheCocos *ppc = [[ProfilePictureCacheCocos alloc] initWithUsername:u sprite:sprite tableView:tableView index:idx];
    //asynchronous
    [ppc performSelectorInBackground:@selector(getImage) withObject:nil];
}

//Method to set profile picture to generic sprite
+(void)setProfilePicture:(NSString *)u forSprite: (CCSprite*)sprite
{
	ProfilePictureCacheCocos *ppc = [[ProfilePictureCacheCocos alloc] initWithUsername:u sprite:sprite tableView:nil index:nil];
	//asynchronous
	[ppc performSelectorInBackground:@selector(getImage) withObject:nil];
}

-(id)initWithUsername:(NSString*)u sprite:(CCSprite*)spr tableView:(SWTableView*)tableV index:(NSUInteger)idx
{
	self = [super init];
	username = u;
	sprite = spr;
    tableView=tableV;
    index = idx;
	return self;
}

//Download image from facebook
-(void) downloadImage
{
	//Get username (replace _ with . since all usernames are stored with _ on server
    NSString * uname = [username stringByReplacingOccurrencesOfString:@"_" withString:@"."];
	
	//Get url of facebook pic
	NSString *u;
    
    if (CC_CONTENT_SCALE_FACTOR() == 2.0) //Retina
        u = [NSString stringWithFormat: @"https://graph.facebook.com/%@/picture?width=120&height=120", uname];
    else
        u = [NSString stringWithFormat: @"https://graph.facebook.com/%@/picture?width=60&height=60", uname];
	
	////////This block of code downloads the image
	NSURL *url = [NSURL URLWithString:u];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	if (error || !data){
		return;
	}
	////////This block of code downloads the image
	
	
	////////This block of code saves the image to the "Caches Directory", note the end of the path is "picname" which means it will be stored as username.png
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex: 0] stringByAppendingPathComponent:imageName];
	[data writeToFile: path atomically: TRUE];
	////////This block of code saves the image to the "Caches Directory"
    
	//Call method to update the cell to use the newly downloaded image (needs to be done on the main thread)
	[self performSelectorInBackground:@selector(setImage) withObject:nil];
}

//This method sets the image to the sprite
- (void) setImage
{    
	/////////////This block of code searches for an image named imageName (in this case it will be username.png)
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex: 0] stringByAppendingPathComponent:imageName];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
	////////////This block of code searches for an image named imageName
    
    if (!image)
        return;

    //round off corners of image
    if (CC_CONTENT_SCALE_FACTOR() == 2.0) //Retina
        image = [ImageManipulator makeRoundCornerImage:image :20 :20];
    else
        image = [ImageManipulator makeRoundCornerImage:image :10 :10];
    
//    [[CCRoundedTextureCache sharedTextureCache] addImageAsync:imageName2 withBlock:
//     ^(CCTexture2D* tex){
//         [sprite setTexture:tex];
//     }];
    [self performSelectorOnMainThread:@selector(finalizeImage:) withObject:image waitUntilDone:NO];
}

//finish setting texture to sprite
- (void) finalizeImage: (UIImage*) image;
{
    //Change sprite to the image we got
    CCTexture2D* imageTex = [[CCTextureCache sharedTextureCache] addCGImage:image.CGImage forKey:imageName];
    [sprite setTexture:imageTex];
}

-(void)getImage
{
	//Get the image name and the cell from the dictionary
    if (CC_CONTENT_SCALE_FACTOR() == 2.0) //Retina
        imageName = [username stringByAppendingString:@"-hd.png"];
    else
        imageName = [username stringByAppendingString:@".png"];
	
	/////////////This block of code searches for an image named imageName (in this case it will be username.png)
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex: 0] stringByAppendingPathComponent:imageName];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
	////////////This block of code searches for an image named imageName
	
    
	//If the image has not been downloaded yet, download the image
	if (!image)
		[self downloadImage];
	//Else, set the sprite to display the image and reload the image if it is over a week old
	else
    {
        //Call method to update the cell to use the newly downloaded image (needs to be done on the main thread)
        [self performSelectorInBackground:@selector(setImage) withObject:nil];
        
        NSFileManager* fm = [NSFileManager defaultManager];
		NSDictionary* attrs = [fm attributesOfItemAtPath:path error:nil];
		if (attrs != nil) {
			NSDate *downloadDate = (NSDate*)[attrs objectForKey: NSFileCreationDate];
			NSDate *today = [NSDate date];
			
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			NSDateComponents *dateDifference = [gregorian components:NSWeekCalendarUnit fromDate:downloadDate toDate:today options:0];
			NSUInteger weeksDiff = [dateDifference week];
			
			if (weeksDiff)
				[self downloadImage];
		}
    }
}

@end
