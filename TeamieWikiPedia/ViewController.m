//
//  ViewController.m
//  TeamieWikiPedia
//
//  Created by Mohit Totlani on 17/07/18.
//  Copyright © 2018 test. All rights reserved.
//



#import "ViewController.h"
#import "WikiQuizContent.h"
#import "OptionsTableViewCell.h"

@interface ViewController ()
{
    TextDownloader *tD;
    WikiQuizContent *wqc;
    NSRange selectedBlankCharacterRange;
    NSInteger selectedBlankIndex;
    NSMutableDictionary *selectedAnswers;
    UIActivityIndicatorView *spinner;
}


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.wikiTextView.text=nil;
    [self.wikiTextView setEditable:NO];
    
    //Disabling the buttons
    self.refreshQuiz.enabled=false;
    self.submit.enabled=false;
    

    self.optionsTableView.layer.cornerRadius=10;
    self.optionsTableView.clipsToBounds = YES;
    self.optionsTableView.layer.borderWidth = 2.0;
    self.optionsTableView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.optionsTableView.separatorColor = [UIColor whiteColor];
    
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    tD=[TextDownloader sharedInstance];
    
    [tD downloadData];
    tD.delegate=self;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showError) name:@"Error" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshQuiz) name:@"refreshQuiz" object:nil];
    
    
    
}



-(void)showError
{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"ERROR!"
                                  message:@"Press Ok to Refresh"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //Do some thing here
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   [self.refreshQuiz sendActionsForControlEvents:UIControlEventTouchUpInside];
                                   
                               }];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}





-(void)downLoadCompletedWithData:(NSString *)WikiString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //Enabling the buttons
        self.refreshQuiz.enabled=true;
        self.submit.enabled=true;
        
        wqc= [TextParser parseWikiText:WikiString];
        if (wqc) {
            [spinner stopAnimating];
            [self addBlankstoWikiText:wqc.wikiText];
            selectedAnswers=[[NSMutableDictionary alloc] init];
            [self.optionsTableView reloadData];
        }
        else
        {
            [self.refreshQuiz sendActionsForControlEvents:UIControlEventTouchUpInside];
            
        }
    });
    
}


-(void)addBlankstoWikiText:(NSString*)wikiText
{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:wikiText];
    
    UIFont *font = [UIFont systemFontOfSize:15.0];
    [attributedString setAttributes:@{NSFontAttributeName:font} range:NSMakeRange(0, [wikiText length])];
    
    
    for (int i=(int)[wqc.answerRanges count]; i>0; i--) {
        
        [attributedString addAttribute:NSLinkAttributeName
                                 value:[NSString stringWithFormat:@"answer://%d",i]
                                 range:[wqc.answerRanges[i-1] rangeValue]];
        
        [attributedString replaceCharactersInRange:[[wqc.answerRanges objectAtIndex:i-1] rangeValue] withString:[NSString stringWithFormat:@"#%d_____",i]];
        
    }
    
    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor orangeColor],
                                     NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                     NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
    
    self.wikiTextView.linkTextAttributes = linkAttributes;
    self.wikiTextView.attributedText = attributedString;
    
}


- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"answer"]) {
        NSString *answerNo = [URL host];
        selectedBlankIndex=[answerNo integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showOptionsTableView];
            selectedBlankCharacterRange=characterRange;
            
        });
        return NO;
    }
    return NO;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)submitQuizAnswer:(id)sender {
    
    int marks=0;
    for (int i=0; i<[wqc.answerRanges count]; i++) {
        NSLog(@"%@",wqc.answers);
        NSLog(@"%@",selectedAnswers);
        if ([[wqc.answers objectAtIndex:i] isEqualToString:[selectedAnswers valueForKey:[NSString stringWithFormat:@"%d",i + 1]]]) {
            marks++;
        }
    }
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Score Baord!"
                                  message:[NSString stringWithFormat:@"You got %d marks",marks]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"NewGame"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //Do some thing here
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   [self.refreshQuiz sendActionsForControlEvents:UIControlEventTouchUpInside];
                                   
                               }];
    
    UIAlertAction* backButton = [UIAlertAction
                                 actionWithTitle:@"Back"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                     
                                 }];
    [alert addAction:backButton];
    [alert addAction:okButton];
    
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (IBAction)refreshQuiz:(id)sender {
    
    //Enabling the buttons
    self.refreshQuiz.enabled=false;
    self.submit.enabled=false;
    [spinner startAnimating];
    selectedAnswers=nil;
    wqc=nil;
    self.wikiTextView.text=nil;
    [self hideOptionsTableView];
    [tD downloadData];
    
    
}



//table view

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (wqc) {
        return [wqc.shuffledOptions count];
    }
    else
    {
        return 0;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 30)];
    [label setFont:[UIFont boldSystemFontOfSize:20]];
    [label setTextAlignment:NSTextAlignmentCenter];
    NSString *string =@"Pick a Word";
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OptionsTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"OptionsTableViewCell"];
    if (cell==nil) {
        cell=[[OptionsTableViewCell alloc] init];
    }
    if (wqc) {
        cell.option.text=[wqc.shuffledOptions objectAtIndex:indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableAttributedString *sampleText = [[NSMutableAttributedString alloc] initWithAttributedString:self.wikiTextView.attributedText];
    
    [sampleText replaceCharactersInRange:selectedBlankCharacterRange withString:[NSString stringWithFormat:@"#%ld %@",(long)selectedBlankIndex,[wqc.shuffledOptions objectAtIndex:indexPath.row]]];
    
    [selectedAnswers setValue:[wqc.shuffledOptions objectAtIndex:indexPath.row] forKey:[NSString stringWithFormat:@"%ld",(long)selectedBlankIndex]];
    
    self.wikiTextView.attributedText=sampleText;
    [self hideOptionsTableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)showOptionsTableView{
    
    if (self.optionsTableView.frame.size.height == 0) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             CGRect frame = self.optionsTableView.frame;
                             if ([wqc.shuffledOptions count]*40 > self.view.frame.size.height/2) {
                                 frame.origin.y= frame.origin.y-self.view.frame.size.height/2;
                                 frame.size.height = self.view.frame.size.height/2;
                                 self.optionsTableView.frame = frame;
                             }
                             else
                             {
                                 frame.origin.y= frame.origin.y-[wqc.shuffledOptions count]*40;
                                 frame.size.height = [wqc.shuffledOptions count]*40;
                                 self.optionsTableView.frame = frame;
                                 
                             }
                             
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    
    
}

-(void)hideOptionsTableView{
    
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.optionsTableView.frame;
                         frame.origin.y= frame.origin.y+frame.size.height;
                         frame.size.height = 0;
                         self.optionsTableView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}


@end

