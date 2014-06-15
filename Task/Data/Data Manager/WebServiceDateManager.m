//
//  WebServiceDateManager.m
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import "WebServiceDateManager.h"
#import "WebServiceBase.h"
@implementation WebServiceDateManager

+(void)getProductObjectResponseFrom:(ProductObjectRequest *)request forDelegate:(id<WebServiceDelegate>)delegate
{
    [WebServiceBase sendWebServiceRequestFor:WebServiceMethodProductObject userInfo:request delegate:delegate];
}


@end
