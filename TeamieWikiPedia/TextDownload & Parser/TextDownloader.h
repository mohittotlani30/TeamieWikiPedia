//
//  TextDownloader.h
//  TeamieWikiPedia
//
//  Created by Mohit Totlani on 17/07/18.
//  Copyright © 2018 test. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadCompleteDelegate <NSObject>
- (void)downLoadCompletedWithData:(NSString *)WikiString;
@end


@interface TextDownloader : NSObject
+(instancetype)sharedInstance;
-(void)downloadData;
@property (nonatomic, weak) id <DownloadCompleteDelegate> delegate;
@end


