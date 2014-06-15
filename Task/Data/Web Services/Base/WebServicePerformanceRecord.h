//
//  WebServicePerformanceRecord.h
//  Task
//
//  Created by Muhammad Saad on 6/14/14.
//  Copyright (c) 2014 Namshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServicePerformanceRecord : NSObject

@property (nonatomic, copy) NSString *requestName;
@property (nonatomic) NSTimeInterval maxDownloadTime;
@property (nonatomic) NSTimeInterval minDownloadTime;
@property (nonatomic) NSTimeInterval avgDownloadTime;

@property (nonatomic) NSTimeInterval maxResponseSize;
@property (nonatomic) NSTimeInterval minResponseSize;
@property (nonatomic) NSTimeInterval avgResponseSize;

@property (nonatomic) NSUInteger noOfCalls;
@property (nonatomic) BOOL isProduction;

@end
