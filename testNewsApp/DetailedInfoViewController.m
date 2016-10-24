//
//  DetailedInfoViewController.m
//  testNewsApp
//
//  Created by Ostrynskii on 21/10/2016.
//  Copyright © 2016 Vladislav Patrashkov. All rights reserved.
//

#import "DetailedInfoViewController.h"

@interface DetailedInfoViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation DetailedInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.url) {
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
	}
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}
@end
