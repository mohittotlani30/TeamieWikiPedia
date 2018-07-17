//
//  TextParser.m
//  TeamieWikiPedia
//
//  Created by Mohit Totlani on 17/07/18.
//  Copyright © 2018 test. All rights reserved.
//

#import "TextParser.h"
#import "NSMutableArray+Shuffling.h"

@implementation TextParser

+(WikiQuizContent *)parseWikiText:(NSString *)wikiText{

    WikiQuizContent *wqc=[[WikiQuizContent alloc] init];

    //For Split into Sentences
    __block NSMutableArray *selectedWords=[[NSMutableArray alloc] init];
    __block NSMutableArray *selectedwordRanges=[[NSMutableArray alloc] init];
    
    NSRange range = {0, [wikiText length]};
    
    [wikiText enumerateSubstringsInRange:range options:NSStringEnumerationBySentences usingBlock:^(NSString *sentence, NSRange substringRange, NSRange enclosingRange, BOOL *stopSentence) {
    
        //For spliting into words
        NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSArray arrayWithObject:NSLinguisticTagSchemeLexicalClass] options:~NSLinguisticTaggerOmitWords];
        [tagger setString:sentence];
        
        __block NSMutableArray *words=[[NSMutableArray alloc] init];
        __block NSRange wordRange;
        wordRange.location=substringRange.location;
        [tagger enumerateTagsInRange:NSMakeRange(0, [sentence length])
                              scheme:NSLinguisticTagSchemeLexicalClass
                             options:~NSLinguisticTaggerOmitWords
                          usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                              
                              if ([tag isEqualToString:@"Noun"]) {
                                  if (![words containsObject:[sentence substringWithRange:tokenRange]]) {
                                      [words addObject:[sentence substringWithRange:tokenRange]];
                                    }
                               }
                          }];
        
        if([words count]>0)
        {
            while (true) {
                NSString *selectedword=[words objectAtIndex:arc4random()%[words count]];
                if (![selectedWords containsObject:selectedword] && [selectedword length]>2) {
                    [selectedWords addObject:selectedword];
                    wordRange.length=[selectedword length];
                    wordRange.location=wordRange.location+[sentence rangeOfString:selectedword].location;
                    [selectedwordRanges addObject:[NSValue valueWithRange:wordRange]];
                    break;
                }
            }
            
        }
        if ([selectedWords count]==10) {
            wqc.wikiText=[wikiText substringWithRange:NSMakeRange(0, substringRange.location+substringRange.length)];
            *stopSentence=YES;
        }
        
    }];
    
    wqc.answers=selectedWords;
    wqc.shuffledOptions=[selectedWords shuffle];
    wqc.answerRanges=selectedwordRanges;
    
    
    /*
     NSLog(@"%@",WQC.answers);
     NSLog(@"%@", WQC.shuffledOptions);
     NSLog(@"%@",WQC.answerRanges);
     NSLog(@"%@",WQC.wikiText);
     */
    
    if ([selectedWords count]!=10) {
        return nil;
    }
    
    return wqc;
}

@end
