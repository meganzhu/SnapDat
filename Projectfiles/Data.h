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
@property (nonatomic) NSString *opponent, *username, *friendFullName, *playerName, *opponentName, *promptForMe, *myPicPath;
@property (nonatomic) NSArray *games;
@property (nonatomic) BOOL new, inPrompt, isPrePhotoTesting;

+(Data*) sharedData;
@end
