//
//  DetailViewController.m
//  Task
//
//  Created by Muhammad Saad on 6/15/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (nonatomic, weak)IBOutlet UIWebView *webView;

@end

@implementation DetailViewController
@synthesize obj;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = obj.productName;
    NSURL *URL = [NSURL URLWithString:obj.productPage];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:URL];
    _webView.delegate = self ;
    [_webView loadRequest:requestObj];

    // Do any additional setup after loading the view.
}
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // log the paramter, as I don't know what to do with it right now
    NSURL *URL = [request URL];
    if ([[URL scheme] isEqualToString:@"namshi"])
    {
        // now we need to figure out the function part
        NSString *functionString = [URL resourceSpecifier];
        if ([functionString hasPrefix:@"message"])
        {
            NSArray *components = [functionString componentsSeparatedByString:@"="];
            NSString *value = [components objectAtIndex:1];
            ALERT(@"Message", value);
        }
    }
    
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
