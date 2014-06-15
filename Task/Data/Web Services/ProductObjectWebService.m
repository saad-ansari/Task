//
//  ProductObjectWebService.m
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import "ProductObjectWebService.h"
#import "ProductObjectRequest.h"
#import "ProductObjectResponse.h"
@implementation ProductObjectWebService

- (id) init
{
    if(self = [super init])
    {
        webServiceMethod = WebServiceMethodProductObject; //Assigning the webServiceType Compulsory else webService get confuse for responing to webService method
    }
    return self;
}

#pragma mark - Overridable methods
- (void) setProperties
{
    ProductObjectRequest *request = (ProductObjectRequest *)self.userInfo;
    self.requestUrl = [NSString stringWithFormat:kProductObjectURL,request.fromValue,request.countValue]; // Assigning the variables values to URL
    [super setProperties];
}

- (void)parseWebResponse
{
    NSData *responsedata = [strResponseData dataUsingEncoding:NSUTF8StringEncoding]; //Converting the JSON String into NSData
    id json = [NSJSONSerialization JSONObjectWithData:responsedata options:0 error:nil]; //Converting the NSData into JSON Object
    NSDictionary *dictProductObject = (NSDictionary *)json;
    NSArray *array = dictProductObject[@"Product"];
    NSMutableArray *responseArray = [NSMutableArray new];
    for (NSDictionary *dic in array) { //Parsing of JSON Object
        ProductObjectResponse *response = [ProductObjectResponse new];
        response.productBrand       = dic[@"brandName"];
        response.productID          = dic[@"id"];
        response.productImage       = dic[@"image"];
        response.productName        = dic[@"productName"];
        response.productPage        = dic[@"productPage"];
        response.productPrice       = dic[@"price"];
        response.productSKU         = dic[@"sku"];

        [responseArray addObject:response];
    }
    responseData = responseArray; // Assigning the Parsed array to Response Object
    [super parseWebResponse];
}

@end
