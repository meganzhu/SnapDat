//
//  PictureCache.m
//  Ghost
//
//  Created by Ashutosh Desai on 11/9/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "ProfilePictureCache.h"

@implementation ProfilePictureCache

-(id)initWithUsername:(NSString*)u andImageView:(UIImageView*)iv inTableView:(UITableView*)tv forIndexPath:(NSIndexPath*)ip
{
	self = [super init];
	//Save instance variables, tView and indexPath will be nil if imageView is not in tableViewCell
	username = u;
	imageView = iv;
	tView = tv;
	indexPath = ip;
	
	return self;
}

//Download Image from facebook
- (void) downloadImage
{
	//Get username (replace _ with . since all usernames are stored with _ on server
    NSString * uname = [username stringByReplacingOccurrencesOfString:@"_" withString:@"."];
	
	//Get url of facebook pic
	NSString *u = [NSString stringWithFormat: @"https://graph.facebook.com/%@/picture?type=large", uname];
	
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
	
	//Name to save the picture (username.png)
	NSString *picname = [username stringByAppendingString:@".png"];
	
	////////This block of code saves the image to the "Caches Directory", note the end of the path is "picname" which means it will be stored as username.png
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex: 0] stringByAppendingPathComponent:picname];
	[data writeToFile: path atomically: TRUE];
	////////This block of code saves the image to the "Caches Directory"

	//Call method to update the cell to use the newly downloaded image (needs to be done on the main thread)
	[self performSelectorOnMainThread:@selector(setImage) withObject:nil waitUntilDone:NO];
}

//This method sets the image to imageView
- (void)setImage
{
	//If imageView no longer exists, do nothing
	if (!imageView)
		return;
	
	//If the imageView was in a tableViewCell, and the cell is no longer visible or doesn't exist, do nothing
	if (tView)
	{
		UITableViewCell *cell = [tView cellForRowAtIndexPath:indexPath];
		if (!cell)
			return;
	}
	
	//Get the image name and the cell from the dictionary
	NSString* imageName = [username stringByAppendingString:@".png"];
	
	//Makes sure the cell is still visible (if not no point in updating the image)

	/////////////This block of code searches for an image named imageName (in this case it will be username.png)
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex: 0] stringByAppendingPathComponent:imageName];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
	////////////This block of code searches for an image named imageName

	//If the image exists, set the imageView to display this image
	if (image)
		imageView.image = image;
}

-(void)getImage
{
	//Get the image name and the cell from the dictionary
	NSString* imageName = [username stringByAppendingString:@".png"];
	
	/////////////This block of code searches for an image named imageName (in this case it will be username.png)
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex: 0] stringByAppendingPathComponent:imageName];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
	////////////This block of code searches for an image named imageName
	
	//Make sure this fits in the desired image container
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.clipsToBounds = TRUE;
	
	//If the image has not been downloaded yet, download the image
	if (!image)
		[self downloadImage];
	//Else, set the imageView to display the image and reload the image if it is over a week old
	else
	{
		imageView.image = image;
		
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

//Method to set profile picture to generic image view
+(void)setProfilePicture:(NSString*)u forImageView:(UIImageView*)iv
{
	ProfilePictureCache *ppc = [[ProfilePictureCache alloc] initWithUsername:u andImageView:iv inTableView:nil forIndexPath:nil];
	
	//Get Image asynchronously
	[ppc performSelectorInBackground:@selector(getImage) withObject:nil];
}

//Method to set profile picture to image view residing in a table view cell (needs to be treated differently since table views reuse cells)
+(void)setProfilePicture:(NSString *)u forImageView:(UIImageView *)iv inTableView:(UITableView*)tv forIndexPath:(NSIndexPath*)ip
{
	ProfilePictureCache *ppc = [[ProfilePictureCache alloc] initWithUsername:u andImageView:iv inTableView:tv forIndexPath:ip];
	
	//Get Image asynchronously
	[ppc performSelectorInBackground:@selector(getImage) withObject:nil];
}

@end
