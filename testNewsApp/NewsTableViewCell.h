//
//  NewsTableViewCell.h
//  testNewsApp
//
//  Created by Vladislav on 10/20/16.
//  Copyright © 2016 Vladislav Patrashkov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;

@end
