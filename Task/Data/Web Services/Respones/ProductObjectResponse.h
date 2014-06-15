//
//  ProductObjectResponse.h
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductObjectResponse : NSObject

//Response Objects
@property (nonatomic, retain) NSString * productID;
@property (nonatomic, retain) NSString * productSKU;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productBrand;
@property (nonatomic, retain) NSString * productImage;
@property (nonatomic, retain) NSString * productPrice;
@property (nonatomic, retain) NSString * productPage;
@end
