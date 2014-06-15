//
//  WebServiceDelegate.h
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceConstants.h"

@class WebServiceBase;

@protocol WebServiceDelegate <NSObject>

/**
 * once the responce is coming this delegate method is getting called in the main thread.
 * @author Muhammad Saad
 * @param webService Requested WebService
 * @param response response from the server. can be anything
 * @return nothing is returning
 */
@required
- (void) responseRecievedFor:(WebServiceBase*)webService withResponse:(NSObject*)response;

/*! Add new message between source to destination timeline as empty name string
 * \param sourceId Source timeline entity ID
 * \param destId Destination timeline entity ID
 * \returns A newly created message instance
 */
@optional
- (void) responseRecievedForWebMethod:(WebServiceMethod)webServiceMethod withResponse:(NSObject*)response;

/// Add new message between source to destination timeline
///
/// @param sourceId Source timeline entity ID
/// @param destId Destination timeline entity ID
/// @param name Message name
/// @return A newly created message instance
@optional
- (void) invalidResponseRecivedFor:(WebServiceBase*)webService withResponse:(NSObject*)response;

@optional
- (void) timeoutOccuredForWebService:(WebServiceBase*)webService;

@optional
- (void) connectionFailedForWebService:(WebServiceBase*)webService error:(NSError*)error;

@optional
- (void) connectionDidFailedWithException:(WebServiceBase*)webService exception:(NSException*)exception;

@optional
- (void) invalidCredentialsRecievedForWebService:(WebServiceBase*)webService;

@end



@protocol WebServiceDataManagerDelegate <WebServiceDelegate>

@end
