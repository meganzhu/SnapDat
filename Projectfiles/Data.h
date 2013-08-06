//
//  Data.h
//  pic3
//
//  Created by user on 7/11/13.
//
//

#import <Foundation/Foundation.h>

@interface Data : NSObject

@property (nonatomic) NSMutableDictionary* game, *user, *userInfo;
@property (nonatomic) NSString *opponent, *username, *friendFullName, *playerName, *opponentName, *prompt, *myPicPath, *guess;
@property (nonatomic) NSArray *games, *prompts;
@property (nonatomic) BOOL new, inPhoto, isPrePhotoTesting;

+(Data*) sharedData;
@end
