//
//  ProfilePictureCacheCocos.h
//  Ghost
//
//  Created by Brian Chu on 12/6/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

@class SWTableView;
@interface ProfilePictureCacheCocos: NSObject
{
    
    //Username of profile picture to pull
	NSString *username;
    
    //full image filename
    NSString* imageName;
    
    //Sprite to set texture on
    CCSprite* sprite;
    
    //Table view of cell with sprite
    SWTableView* tableView;
    
    //Index of cell with sprite
    NSUInteger index;
}
+(void)setProfilePicture:(NSString *)u forSprite: (CCSprite*)sprite tableView: (SWTableView*) tableView index:(NSUInteger)idx;
+(void)setProfilePicture:(NSString *)u forSprite: (CCSprite*)sprite;


@end
