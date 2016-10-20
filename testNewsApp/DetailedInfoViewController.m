//
//  DetailedInfoViewController.m
//  testNewsApp
//
//  Created by Ostrynskii on 21/10/2016.
//  Copyright © 2016 Vladislav Patrashkov. All rights reserved.
//

#import "DetailedInfoViewController.h"

@interface DetailedInfoViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DetailedInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.url) {
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
	}
}
@end
