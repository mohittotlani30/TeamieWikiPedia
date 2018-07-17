//
//  TextParser.h
//  TeamieWikiPedia
//
//  Created by Mohit Totlani on 17/07/18.
//  Copyright © 2018 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WikiQuizContent.h"

@interface TextParser : NSObject

+(WikiQuizContent *)parseWikiText:(NSString *)wikiText;

@end
