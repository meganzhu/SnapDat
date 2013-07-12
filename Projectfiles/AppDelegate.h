//
//  AppDelegate.h
//  Ghost
//
//  Created by Brian Chu on 10/29/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "KKAppDelegate.h"
#import "Data.h"

@interface AppDelegate : KKAppDelegate
{
    Data* data;
}
extern NSMutableDictionary* user;
extern BOOL noPush;
extern NSMutableArray *words;



@end

@compatibility_alias AppController AppDelegate;
