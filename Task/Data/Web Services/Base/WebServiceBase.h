//
//  WebServiceBase.h
//  EServices
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WebServiceDelegate.h"
#import "WebServiceConstants.h"

@interface WebServiceBase : NSObject <NSURLConnectionDataDelegate, NSXMLParserDelegate>
{
    //hide iVars here without declaring the .h file. (encapsulate data)
    NSMutableURLRequest *urlRequest;
    
    //can be override by the sub classes
    @protected
    NSString *strRequestData;
    NSString *strSoapAction;
    NSString *templateFileName;
    NSString *webServiceURL;
    
    NSString *currentElementName;
    NSMutableString *currentElementContents;
    NSString *currentAttribute;
    
    BOOL isHardCodedMode;
    NSString *hardCodedFilePath;
    
    NSString *strResponseData;
    NSObject *responseData;
    NSTimeInterval httpTimeOut;
    NSMutableData *mutableResponseData;
    NSObject *dataManagerResponse;
    
    NSTimeInterval startTime;
    NSTimeInterval xmlParsingTime;
    WebServiceMethod webServiceMethod;
    /*
    //There are 2 kinds. Property attributes and Variable attributes 
    @private
    NSObject *a; // this is retained/released automatically. simmlar to __Strong NSObject *a;
    __strong NSObject *aa; //same as above.
    __weak NSObject *b; // this is a weak, zeroing link. pointing to nil when the poiting objects get deallocated. supports only in iOS > 5
    __unsafe_unretained NSObject *c; // how instance variables used to work, simillar to assign. causes crashes. supports for iOS 4
    */
}

///Delegate to be called
@property (nonatomic, weak, readonly) id<WebServiceDelegate> serviceDelegate;
@property (nonatomic, weak, readonly) id<WebServiceDataManagerDelegate> dataManagerDelegate;
@property (nonatomic, strong, readonly) NSObject *userInfo;
@property (nonatomic, readonly) WebServiceMethod webServiceMethod;
@property (nonatomic,strong)NSString *requestUrl;

//designated initializers
- (instancetype) initWithDelegate:(id<WebServiceDelegate>)delegate;
- (instancetype) initWithDelegate:(id<WebServiceDelegate>)delegate userInfo:(NSObject*)info;

//set web service parameters
- (void) setProperties;
- (void)parseWebResponse;

+ (void) sendWebServiceRequestFor:(WebServiceMethod)method userInfo:(NSObject*)info delegate:(id<WebServiceDelegate>)delegate andDataManagerDelegate:(id<WebServiceDataManagerDelegate>)dataManagerDelegate;
+ (void) sendWebServiceRequestFor:(WebServiceMethod)method userInfo:(NSObject*)info delegate:(id<WebServiceDelegate>)delegate;

@end
