//
//  ViewController.m
//  testNewsApp
//
//  Created by Vladislav on 10/20/16.
//  Copyright © 2016 Vladislav Patrashkov. All rights reserved.
//

#import "ViewController.h"
#import "NewsTableViewCell.h"
#import "DetailedInfoViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <RNFrostedSidebar/RNFrostedSidebar.h>


typedef enum {
    kNotSpecified,
    kAllNews,
    kCategorizedNews,
} NewsType;

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, RNFrostedSidebarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *responseJSONArray;
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) NSArray *categoriesPictures;
@property (assign, nonatomic) NewsType newsType;
@property (strong, nonatomic) RNFrostedSidebar *frostedSidebar;

@property (strong, nonatomic) NSString *urlForDetails;

@end
// url and apiKey
static NSString *const kUrlNewsDefault = @"https://newsapi.org/v1/articles?source=techcrunch";
static NSString *const kCategoryURL = @"https://newsapi.org/v1/sources?category=";
static NSString *const kAPIKEY = @"262fcd3d295b4304ba053ac59ef70492";
// category
static NSString *const kTopNews = @"top";
static NSString *const kBusiness = @"business";
static NSString *const kEntertainment = @"entertainment";
static NSString *const kGaming = @"gaming";
static NSString *const kGeneral = @"general";
static NSString *const kMusic = @"music";
static NSString *const kScienceAndNature = @"science-and-nature";
static NSString *const kSport = @"sport";
static NSString *const kTechnology = @"technology";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pickerData = @[kTopNews, kBusiness, kEntertainment, kGaming, kGeneral, kMusic, kScienceAndNature, kSport, kTechnology];
    self.newsType = kNotSpecified;
    
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self loadAllNews];
    [self customizeSidePanel];
}

- (IBAction)categoryAction:(id)sender {
    [self.frostedSidebar show];
}

- (void)customizeSidePanel {
    self.categoriesPictures = @[[UIImage imageNamed:@"top"],
                                [UIImage imageNamed:@"business"],
                                [UIImage imageNamed:@"entertainment"],
                                [UIImage imageNamed:@"gaming"],
                                [UIImage imageNamed:@"general"],
                                [UIImage imageNamed:@"music"],
                                [UIImage imageNamed:@"science-and-nature"],
                                [UIImage imageNamed:@"sport"],
                                [UIImage imageNamed:@"technology"]];
    self.frostedSidebar = [[RNFrostedSidebar alloc] initWithImages:self.categoriesPictures];
    self.frostedSidebar.delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showInfo"]) {
        DetailedInfoViewController *detailInfo = segue.destinationViewController;
        detailInfo.url = self.urlForDetails;
    }
}


#pragma mark - LoadDataWithURL
- (void)loadAllNews {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSString *urlString = [NSString stringWithFormat:@"%@&apiKey=%@", kUrlNewsDefault, kAPIKEY];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            self.newsType = kAllNews;
            self.responseJSONArray = responseObject[@"articles"];
            [self.tableView reloadData];
        }
    }];
    [dataTask resume];
}

- (void)loadDataForCategory:(NSString *)category {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kCategoryURL, category];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            self.newsType = kCategorizedNews;
            self.responseJSONArray = responseObject[@"sources"];
            [self.tableView reloadData];
            NSLog(@"%@",self.responseJSONArray);
        }
    }];
    [dataTask resume];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.responseJSONArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *newsInfo = self.responseJSONArray[indexPath.row];
    
    NSString *titleString = nil;
    NSString *descriptionString = nil;
    NSString *imageURL = nil;
    switch (self.newsType) {
        case kAllNews: {
            titleString = newsInfo[@"title"];
            descriptionString = newsInfo[@"description"];
            imageURL = newsInfo[@"urlToImage"];
        }
            break;
        case kCategorizedNews: {
            titleString = newsInfo[@"name"];
            descriptionString = newsInfo[@"description"];
            imageURL = newsInfo[@"urlsToLogos"][@"medium"];
        }
            break;
        default:
            break;
    }
    
    // text
    NSString *formattedString = [NSString stringWithFormat:@"%@\n\n%@", titleString, descriptionString];
    cell.descriptionLabel.text = formattedString;
    
    // image
    [cell.newsImageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"imagePlaceholder"]];
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *newsInfo = self.responseJSONArray[indexPath.row];
    self.urlForDetails = newsInfo[@"url"];
    [self performSegueWithIdentifier:@"showInfo" sender:self];
}


#pragma mark - RNFrostedSidebarDelegate
- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    NSString *category = self.pickerData[index];
    if ([category isEqualToString:kTopNews]) {
        [self loadAllNews];
        [sidebar dismiss];
    }
    else if ([category isEqualToString:kBusiness]) {
        [self loadDataForCategory:kBusiness];
        [sidebar dismiss];
    }
    else if ([category isEqualToString:kSport]) {
        [self loadDataForCategory:kSport];
        [sidebar dismiss];
    }
    else if ([category isEqualToString:kEntertainment]) {
        [self loadDataForCategory:kEntertainment];
        [sidebar dismiss];
    }
    else if ([category isEqualToString:kMusic]) {
        [self loadDataForCategory:kMusic];
        [sidebar dismiss];
    }
    else if ([category isEqualToString:kGaming]) {
        [self loadDataForCategory:kGaming];
        [sidebar dismiss];
    }
    else if ([category isEqualToString:kScienceAndNature]) {
        [self loadDataForCategory:kScienceAndNature];
        [sidebar dismiss];
    }
    else if ([category isEqualToString:kGeneral]) {
        [self loadDataForCategory:kGeneral];
        [sidebar dismiss];
    }
    else if ([category isEqualToString:kTechnology]) {
        [self loadDataForCategory:kTechnology];
        [sidebar dismiss];
    }
}

@end
