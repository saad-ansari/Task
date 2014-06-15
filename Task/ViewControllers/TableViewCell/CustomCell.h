//
//  CustomCell.h
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell :  UITableViewCell
{
    
}
@property(nonatomic, strong) IBOutlet UILabel           *lblName;
@property(nonatomic, strong) IBOutlet UILabel           *lblPrice;
@property(nonatomic, strong) IBOutlet UIImageView       *imgMain;
+ (id) createCell;
@end
