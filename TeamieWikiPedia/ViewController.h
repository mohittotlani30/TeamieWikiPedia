//
//  ViewController.h
//  TeamieWikiPedia
//
//  Created by Mohit Totlani on 17/07/18.
//  Copyright © 2018 test. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TextDownloader.h"
#import "TextParser.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController :UIViewController<DownloadCompleteDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITextView *wikiTextView;
@property (strong, nonatomic) IBOutlet UIButton *submit;
@property (strong, nonatomic) IBOutlet UIButton *refreshQuiz;
@property (strong, nonatomic) IBOutlet UITableView *optionsTableView;

@end

