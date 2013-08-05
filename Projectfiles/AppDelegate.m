//
//  AppDelegate.m
//  Ghost
//
//  Created by Brian Chu on 10/29/12.
//  Copyright (c) 2012 makegameswithus inc. Free to use for all purposes.
//

#import "AppDelegate.h"
#import "InterfaceLayer.h"
#import "GamesTableLayer.h"
#import "GameLayer.h"
#import "ChatLayer.h"

@implementation AppDelegate

NSMutableDictionary* user;
BOOL noPush;
NSMutableArray *words;

-(void) initializationComplete
{
#ifdef KK_ARC_ENABLED
	CCLOG(@"ARC is enabled");
#else
	CCLOG(@"ARC is either not available or not enabled");
#endif
    
	[MGWU loadMGWU:@"thisisaghettoassgameandeveryoneshouldplayit"];
    
    [MGWU useS3WithAccessKey:nil andSecretKey:nil];
	
    [MGWU dark];
    
	[MGWU forceFacebook];
	
	[MGWU setReminderMessage:@"Come back and play Ghost!"];
	
	//To flag whether push notifications are disabled
	noPush = NO; //not disabled
    
    //In Kobold+iOS 5 the call to initializationComplete occurs after applicationDidBecomeActive
	//This causes a problem in the mgwuSDK, so here is dirty hack to fix it
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
		[[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    
}

-(id) alternateView
{
	return nil;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)tokenId {
	[MGWU registerForPush:tokenId];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    data = [Data sharedData];
    [MGWU gotPush:userInfo];
	
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
	{
		//Auto refresh views when a message or move has been received (push notification)
		//If move has been received
        CCScene* runningScene = CCDirector.sharedDirector.runningScene;
        if ([[userInfo allKeys] containsObject:@"gameid"])
        {
            
            for (CCNode* child in runningScene.children)
            {
			//if current view is in game, refresh the game
                if ([child isMemberOfClass: [GameLayer class]])
                {
                    GameLayer* gameLayer = (GameLayer*) child;
                    if ([[data.game objectForKey:@"gameid"] isEqualToNumber:[userInfo objectForKey:@"gameid"]])
                        [gameLayer refresh];
                    break;
                    
                }
                //Else if the current view displayed is the InterfaceLayer, refresh list of games
                else if ([child isMemberOfClass:[InterfaceLayer class]])
                {
                    [(InterfaceLayer*) child refresh];
                    break;
                }
            }
        }
		//If message has been received
        else if ([[userInfo allKeys] containsObject:@"from"])
        {
            for (CCNode* child in runningScene.children)
            {
			//If the current view is in the chat, refresh the chat
                if ([child isMemberOfClass:[ChatLayer class]])
                {
                    ChatLayer *chatTableLayer = (ChatLayer*)child;
                    if ([chatTableLayer.friendID isEqualToString:[userInfo objectForKey:@"from"]])
                        [chatTableLayer refresh];
                }
				else if ([child isMemberOfClass: [GameLayer class]])
                {
                    GameLayer* gameLayer = (GameLayer*) child;
                    if ([data.opponentName isEqualToString:[userInfo objectForKey:@"from"]])
                        [gameLayer refresh];
                    break;
                    
                }
                else if ([child isMemberOfClass:[InterfaceLayer class]])
                {
                    [(InterfaceLayer*) child refresh];
                    break;
                }
            }
        }
    }
    else
	{
		if ([[userInfo allKeys] containsObject:@"gameid"])
			[MGWU logEvent:@"push_clicked" withParams:@{@"type":@"move"}];
		else if ([[userInfo allKeys] containsObject:@"from"])
			[MGWU logEvent:@"push_clicked" withParams:@{@"type":@"message"}];
	}
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    [MGWU failedPush:error];
	noPush = YES; //push is disabled
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	[MGWU gotLocalPush:notification];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    CCScene* runningScene = CCDirector.sharedDirector.runningScene;
//    for (CCNode* child in runningScene.children)
//        if ([child isMemberOfClass: [GuessLayer class]])
//        {
//            //if you're in a guess, treat it as a challenge (to prevent cheating)
//			[(GuessLayer*)child challenge:nil];
//        }
	
	[director stopAnimation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
	[director startAnimation];
    
    //refresh the layer that is running when the app is entered
    CCScene* runningScene = CCDirector.sharedDirector.runningScene;
    for (CCNode* child in runningScene.children)
    {
        if ([child isMemberOfClass:[InterfaceLayer class]])
        {
            [(InterfaceLayer*) child refresh];
            break;
        }

        if ([child isMemberOfClass: [GameLayer class]])
        {
            [(GameLayer*)child refresh];
            break;
            
        }
        if ([child isMemberOfClass:[ChatLayer class]])
        {
            [(ChatLayer*)child refresh];
            break;
        }
    }
}

-(void) applicationWillResignActive:(UIApplication *)application
{
	[director pause];
}

-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[director resume];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [MGWU handleURL:url];
}

@end
