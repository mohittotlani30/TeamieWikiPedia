//
//  NSArray+Shuffling.m
//  TeamieWikiPedia
//
//  Created by Mohit Totlani on 17/07/18.
//  Copyright © 2018 test. All rights reserved.
//

#import "NSMutableArray+Shuffling.h"

@implementation NSMutableArray (Shuffling)

-(NSArray*)shuffle
{
    NSMutableArray *shuffledArray=[[NSMutableArray alloc] initWithArray:self];
    NSUInteger count = [self count];
    for (uint i = 0; i < count - 1; ++i)
    {
        int nElements = (int)count - i;
        int n = arc4random_uniform(nElements) + i;
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return shuffledArray;
    
}
@end
