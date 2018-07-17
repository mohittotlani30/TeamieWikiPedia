//
//  TextDownloader.m
//  TeamieWikiPedia
//
//  Created by Mohit Totlani on 17/07/18.
//  Copyright © 2018 test. All rights reserved.
//

#import "TextDownloader.h"

@implementation TextDownloader
+(instancetype)sharedInstance{
    
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)downloadData
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:@"https://en.wikipedia.org/w/api.php?format=json&action=query&generator=random&grnnamespace=0&prop=extracts&explaintext="];
    //https://en.wikipedia.org/w/api.php?format=json&generator=random&grnnamespace=0&action=query&prop=extracts&explaintext&redirects=
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error && data!=nil)
        {
            if ([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSError *jsonError=nil;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                
                if (jsonError) {
                    NSLog(@"Json Parsing Error");
                }
                else {
                    if ([[jsonResponse allKeys] containsObject:@"query"]) {
                        
                        NSDictionary *pages= [[jsonResponse objectForKey:@"query"] objectForKey:@"pages"];
                        NSString *WikiExtract=[[pages objectForKey:[[pages allKeys] objectAtIndex:0]] objectForKey:@"extract"];
                        
                        if ([WikiExtract length]>2000) {
                            [self.delegate downLoadCompletedWithData:WikiExtract];
                        }
                        else
                        {
                            [self downloadData];
                        }
                    }
                    else
                    {
                        NSLog(@"No Value for Key");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"Error" object:nil];
                    }
                }
            }
            else
            {
                NSLog(@"Response Error");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Error" object:nil];
            }
        }
        else
        {
            NSLog(@"error : %@", error.description);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Error" object:nil];
        }
    }] ;
    
    [postDataTask resume];
    [session finishTasksAndInvalidate];
}




@end
