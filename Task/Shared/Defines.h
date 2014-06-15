//
//  Defines.h
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//


#import "WebServiceDateManager.h"
#import "ProductObjectRequest.h"
#import "ProductObjectResponse.h"
#import "Product.h"
#import "DBClass.h"


#define kDBName @"DBModel"
#define KProductObject @"Product"

#define ALERT(TITLE,MSG) [[[UIAlertView alloc] initWithTitle:(TITLE) \
message:(MSG) \
delegate:nil \
cancelButtonTitle:@"OK" \
otherButtonTitles:nil] show]
