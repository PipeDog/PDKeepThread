//
//  PDKeepThread.h
//  PDKeepThread
//
//  Created by liang on 2020/6/12.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * _Nullable const PDKeepThreadDefaultName;
FOUNDATION_EXPORT NSUInteger const PDKeepThreadDefaultStackSize;
FOUNDATION_EXPORT NSQualityOfService const PDKeepThreadDefaultQualityOfService;

@interface PDKeepThread : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *threadDictionary;
@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

// Set these properties before starting the thread if needed.
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, assign) NSUInteger stackSize;
@property (nonatomic, assign) NSQualityOfService qualityOfService;

- (instancetype)init;
- (instancetype)initWithName:(nullable NSString *)name
                   stackSize:(NSUInteger)stackSize
            qualityOfService:(NSQualityOfService)qualityOfService NS_DESIGNATED_INITIALIZER;

- (void)executeTaskWithBlock:(void (^)(void))block;
- (void)executeTaskWithBlock:(void (^)(void))block waitUntilDone:(BOOL)wait;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
