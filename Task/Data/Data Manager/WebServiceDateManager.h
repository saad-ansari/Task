//
//  WebServiceDateManager.h
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductObjectRequest.h"
#import "WebServiceDelegate.h"

@interface WebServiceDateManager : NSObject

//Data Manager Method for ProductObject WebService
+(void)getProductObjectResponseFrom:(ProductObjectRequest *)request forDelegate:(id<WebServiceDelegate>)delegate;

@end
