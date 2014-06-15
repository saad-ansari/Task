//
//  WebServiceBase.m
//  EServices
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import "WebServiceBase.h"
#import "ProductObjectWebService.h"
//#import "DataLibSettingsManager.h"

//#import "SQLWebServiceFactory.h"

#pragma mark - class extenstion
@interface WebServiceBase() //class extensions
{
    
}
@end

@implementation WebServiceBase
{
    NSUInteger retryTimes;
    NSTimer *timer;
}

@synthesize webServiceMethod = _webServiceMethod;

- (void) dealloc
{
    NSLog(@"Dealloc : %@", [self description]);
}

#pragma mark - Initialization related
- (id) init
{
    if(self = [super init])
    {
        httpTimeOut = -1;
    }
    return self;
}

- (WebServiceBase*) initWithDelegate:(id<WebServiceDelegate>)delegate
{
    if(self = [self init])
    {
        _serviceDelegate = delegate;
    }
    return self;
}

- (WebServiceBase*) initWithDelegate:(id<WebServiceDelegate>)delegate userInfo:(NSObject*)info
{
    if(self = [self init])
    {
        _serviceDelegate = delegate;
        _userInfo = info;
    }
    return self;
}

- (void) initializeServiceMethod:(WebServiceMethod)method andUserInfo:(NSObject*)userInfo
{
    _webServiceMethod = method;
    _userInfo = userInfo;
}

- (void) initializeServiceDelegate:(id<WebServiceDelegate>)delegate andDataManagerDelegate:(id<WebServiceDataManagerDelegate>)dataManagerDelegate
{
    _serviceDelegate = delegate;
    _dataManagerDelegate = dataManagerDelegate;
}

+ (WebServiceBase *) getWebServiceFactoryForWSType:(WebServiceMethod)method
{
    switch (method) {
        case WebServiceMethodProductObject:
            return [ProductObjectWebService new];
            break;
        default:
            break;
    }
    return nil;

}

+ (WebServiceType) getWebServiceForWebMethod:(WebServiceMethod)method
{
    switch (method)
    {
        default:
            break;
    }
    return WebServiceTypeOracle;
}

+ (WebServiceBase*) getWebServiceForWebMethod:(WebServiceMethod)method webServiceType:(WebServiceType)webServiceType
{
    WebServiceBase *service = [WebServiceBase getWebServiceFactoryForWSType:method];
    return service;
}

+ (void) sendWebServiceRequestFor:(WebServiceMethod)method userInfo:(NSObject*)info delegate:(id<WebServiceDelegate>)delegate andDataManagerDelegate:(id<WebServiceDataManagerDelegate>)dataManagerDelegate
{
    WebServiceType type = [WebServiceBase getWebServiceForWebMethod:method];
    WebServiceBase *targetWebService = [WebServiceBase getWebServiceForWebMethod:method webServiceType:type];
    [targetWebService initializeServiceMethod:method andUserInfo:info];
    [targetWebService initializeServiceDelegate:delegate andDataManagerDelegate:dataManagerDelegate];
    
    [targetWebService sendRequest];
}

+ (void) sendWebServiceRequestFor:(WebServiceMethod)method userInfo:(NSObject*)info delegate:(id<WebServiceDelegate>)delegate
{
    [WebServiceBase sendWebServiceRequestFor:method userInfo:info delegate:delegate andDataManagerDelegate:nil];
}

#pragma mark - Overridable methods

- (void) setProperties
{
    mutableResponseData = [NSMutableData new];
    
    retryTimes++;

    if(httpTimeOut < 0)
    {
        httpTimeOut = KHttpTimeOutInterval;
    }
    if(webServiceURL == nil)
    {
        webServiceURL = _requestUrl;
    }
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:webServiceURL]];
    [urlRequest setTimeoutInterval:httpTimeOut];
    [urlRequest setHTTPMethod:KWebMethodPost];
    [urlRequest addValue:KContentTypeValue forHTTPHeaderField:KContentType];
    
    strRequestData = [strRequestData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSData *postData = [strRequestData dataUsingEncoding:NSUTF8StringEncoding];
    if([postData length] > 0)
    {
        [urlRequest setHTTPBody:postData];
        [urlRequest addValue:[NSString stringWithFormat:@"%lu", (unsigned long)postData.length] forHTTPHeaderField:KContentLength];
    }
    if([strSoapAction length] > 0)
    {
        [urlRequest addValue:strSoapAction forHTTPHeaderField:KSoapAction];
    }
}

- (void) sendRequest
{
    @try
    {
        [self loadWebServiceTemplateFromFile:templateFileName];
        [self setProperties];
        
        if(!isHardCodedMode)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                startTime = [[NSDate date] timeIntervalSince1970];
                [NSURLConnection connectionWithRequest:urlRequest delegate:self];
                timer = [NSTimer scheduledTimerWithTimeInterval:(httpTimeOut + 1) target:self selector:@selector(fireTimeOut) userInfo:nil repeats:NO];
            });
        }
        else
        {
            [self loadHardcodedData];
        }
    }
    @catch (NSException *exception)
    {
        if([self.serviceDelegate respondsToSelector:@selector(connectionDidFailedWithException:exception:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.serviceDelegate connectionDidFailedWithException:self exception:exception];
            });
        }
    }
}

- (void) fireTimeOut
{
    if([self.serviceDelegate  respondsToSelector:@selector(timeoutOccuredForWebService:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.serviceDelegate timeoutOccuredForWebService:self];
            //self.serviceDelegate = nil;
        });
    }
}

#pragma mark - NSURLConnection delegate methods

- (void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    [timer invalidate];
}

- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData*)response
{
    [mutableResponseData appendData:response];
}

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    //inform the user
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], error.userInfo[NSURLErrorFailingURLStringErrorKey]);
    if([self.serviceDelegate respondsToSelector:@selector(connectionFailedForWebService:error:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.serviceDelegate  connectionFailedForWebService:self error:error];
            //self.serviceDelegate = nil;
            if([timer isValid])
            {
                [timer invalidate];
            }
        });
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection*)connection
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(globalQueue, ^{
        
        strResponseData = [[NSString alloc] initWithBytes:mutableResponseData.bytes length:mutableResponseData.length encoding:NSUTF8StringEncoding];
        strResponseData = [strResponseData stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        strResponseData = [strResponseData stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        
        @try
        {
            [self processWebResponse];
            [self logWebServiceData];
        }
        @catch (NSException *exception)
        {
            NSLog(@"%@ in %@ %@", exception.name, self.description, self.serviceDelegate);
            if([self.serviceDelegate respondsToSelector:@selector(connectionDidFailedWithException:exception:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.serviceDelegate connectionDidFailedWithException:self exception:exception];
                });
            }
        }
        @finally
        {
            //[mutableResponseData resetBytesInRange:NSMakeRange(0, mutableResponseData.length)];
        }
    });
}

- (void) connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
    //receive a authenticate and challenge with the user credential
}

#pragma mark - private methods

- (void) logWebServiceData
{

}

- (void) loadHardcodedData
{
//    if(hardCodedFilePath == nil)
//    {
//        hardCodedFilePath = templateFileName;
//    }
//    startTime = [[NSDate date] timeIntervalSince1970];
//    NSError *error = nil;
//    NSString *path = [NSString stringWithFormat:@"%@/%@.xcconfig", [DataLibSettingsManager directoryPathFor:DirectoryPathHardCodedData], hardCodedFilePath];
//    if([[NSFileManager defaultManager] fileExistsAtPath:path])
//    {
//        strResponseData = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
//        mutableResponseData = [NSMutableData dataWithData:[strResponseData dataUsingEncoding:NSUTF8StringEncoding]];
//        [self connectionDidFinishLoading:nil];
//    }
//    else
//    {
//        @throw [NSException exceptionWithName:@"Hardcoded data FileNotFoundException" reason:[NSString stringWithFormat:@"File %@ not found", path] userInfo:nil];
//    }
}

- (void) loadWebServiceTemplateFromFile:(NSString*)fileName
{
    if(fileName)
    {
        NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/WebServiceTemplate/%@.xcconfig", fileName]];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            NSError *error = nil;
            strRequestData = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        else
        {
            @throw [NSException exceptionWithName:@"FileNotFoundException" reason:[NSString stringWithFormat:@"File %@ not found", filePath] userInfo:nil];
        }
    }
}

- (void)parseWebResponse{
    [self fireResponseDelegatsToTargets];
}

- (void) processWebResponse
{
    //if(self.serviceDelegate)
    {
        
        [self parseWebResponse];

        /*
        NSData *responsedata = [strResponseData dataUsingEncoding:NSUTF8StringEncoding];
        //set these response data to NSXMLParser and then start parsing
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responsedata];
        parser.shouldProcessNamespaces = [self shouldProcessNamespaces];
        parser.shouldReportNamespacePrefixes = [self shouldReportNamespacePrefixes];
        parser.delegate = self;
        [parser parse];
         */
         
    }
}

- (BOOL) shouldProcessNamespaces
{
    return FALSE;
}

- (BOOL) shouldReportNamespacePrefixes
{
    return FALSE;
}

- (NSUInteger) retryCount
{
    return retryTimes;
}

#pragma mark - NSXMLParser delegate methods

- (void) parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    [currentElementContents appendString:string];
}

- (void) parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict
{
    currentElementContents = [NSMutableString stringWithString:@""];
    currentElementName = elementName;
}

- (void) parserDidStartDocument:(NSXMLParser*)parser
{
    startTime = [[NSDate date] timeIntervalSince1970];
}

// sent when the parser begins parsing of the document.
- (void) parserDidEndDocument:(NSXMLParser*)parser
{
    xmlParsingTime = [[NSDate date] timeIntervalSince1970] - startTime;
    [self fireResponseDelegatsToTargets];
}

- (void) fireResponseDelegatsToTargets
{
    //NSLog(@"fireResponseDelegatsToTargets");
    if([self.dataManagerDelegate respondsToSelector:@selector(responseRecievedFor:withResponse:)])
    {
        [self.dataManagerDelegate responseRecievedFor:self withResponse:dataManagerResponse];
    }
    [self fireWebServiceDelegate];
}

- (void) fireWebServiceDelegate
{
    if([self.serviceDelegate respondsToSelector:@selector(responseRecievedFor:withResponse:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //NSLog(@"Firing to main thread...");
            [self.serviceDelegate responseRecievedFor:self withResponse:responseData];
        });
    }
}

- (void) parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
    NSLog(@"xml parse error occured : %@", self.description);
    if([self.serviceDelegate respondsToSelector:@selector(invalidResponseRecivedFor:withResponse:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.serviceDelegate invalidResponseRecivedFor:self withResponse:nil];
        });
    }
}

- (void) parser:(NSXMLParser*)parser foundCDATA:(NSData*)CDATABlock
{
    NSLog(@"CData section found");
}

- (NSString*) description
{
    return NSStringFromClass([self class]);
}

@end
