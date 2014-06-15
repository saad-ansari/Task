//
//  DetailViewController.h
//  Task
//
//  Created by Muhammad Saad on 6/15/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Product.h"
@interface DetailViewController : BaseViewController<UIWebViewDelegate>
{
    Product *obj;
}
@property (nonatomic, strong)Product *obj;

@end
