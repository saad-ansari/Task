//
//  WebServiceConstants.h
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KWebMethodPost          @"POST"
#define KWebMethodGet           @"GET"
#define KHttpTimeOutInterval    120
#define KContentTypeValue       @"text/xml; charset=utf-8"
#define KContentType            @"Content-Type"
#define KContentLength          @"Content-Length"
#define KSoapAction             @"SOAPAction"
#define KWebMethodPost          @"POST"
#define KWebMethodGet           @"GET"



#define WebUrl   @""
#define LoginUrl @""
#define kProductObjectURL @"http://www.namshi.com/products?from=%@&count=%@"


typedef NS_ENUM(NSInteger, WebServiceMethod)
{
    WebServiceMethodNone = 0,
    WebServiceMethodProductObject,
    
};


typedef NS_ENUM(NSInteger, WebServiceType)// type checking for enums. stronger type cheking,better code completion
{
    WebServiceTypeNone,
    WebServiceTypeOracle,
    WebServiceTypeSqlite,
};



