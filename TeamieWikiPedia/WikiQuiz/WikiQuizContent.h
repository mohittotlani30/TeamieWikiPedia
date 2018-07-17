//
//  WikiQuizContent.h
//  TeamieWikiPedia
//
//  Created by Mohit Totlani on 17/07/18.
//  Copyright © 2018 test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WikiQuizContent : NSObject
@property (nonatomic,strong) NSArray *answers;
@property (nonatomic,strong) NSArray *answerRanges;
@property (nonatomic,strong) NSArray *shuffledOptions;
@property (nonatomic,strong) NSString *wikiText;
@end
