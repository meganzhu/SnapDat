//
//  Data.m
//  pic3
//
//  Created by Megan Zhu on 7/11/13.
//  NTS: dimensions of iphone: 320x480
//

#import "Data.h"

@implementation Data

static Data *sharedData = nil;


+(Data*) sharedData
{
    //If our singleton instance has not been created (first time it is being accessed)
    if(sharedData == nil)
    {
        //create our singleton instance
        sharedData = [[Data alloc] init];
        
        //collections (Sets, Dictionaries, Arrays) must be initialized
        //Note: our class does not contain properties, only the instance does
        //self.arrayOfDataToBeStored is invalid
//        sharedData.game = [[NSMutableDictionary alloc] init];
    }
    
    //if the singleton instance is already created, return it
    return sharedData;
}

@end
