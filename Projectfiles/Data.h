//
//  Data.h
//  pic3
//
//  Created by user on 7/11/13.
//
//

#import <Foundation/Foundation.h>

@interface Data : NSObject

@property (nonatomic) NSMutableDictionary* game, *user;
@property (nonatomic) NSString *opponent, *username, *friendFullName, *playerName, *opponentName, *promptForMe, *promptForThem;
@property (nonatomic) UIImage *myPic, *theirPic;
@property (nonatomic) BOOL new;

+(Data*) sharedData;
@end
