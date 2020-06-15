//
//  PDKeepThread.m
//  PDKeepThread
//
//  Created by liang on 2020/6/12.
//  Copyright © 2020 liang. All rights reserved.
//

#import "PDKeepThread.h"

NSString *const PDKeepThreadDefaultName = nil;
NSUInteger const PDKeepThreadDefaultStackSize = 1 << 19; // 512KB | 524288 bit
NSQualityOfService const PDKeepThreadDefaultQualityOfService = NSQualityOfServiceDefault;

@interface PDThreadLaunchAction : NSObject

- (void)run:(NSThread *)thread;

@end

@implementation PDThreadLaunchAction

- (void)run:(NSThread *)thread {
    CFRunLoopRef rl = CFRunLoopGetCurrent();
    CFRunLoopSourceContext context = {0};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    CFRunLoopAddSource(rl, source, kCFRunLoopDefaultMode);
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, MAXFLOAT, NO);
    CFRelease(source);
}

@end

@implementation PDKeepThread {
    NSThread *_thread;
}

- (void)dealloc {
    [self stop];
}

- (instancetype)init {
    return [self initWithName:PDKeepThreadDefaultName
                    stackSize:PDKeepThreadDefaultStackSize
             qualityOfService:PDKeepThreadDefaultQualityOfService];
}

- (instancetype)initWithName:(NSString *)name
                   stackSize:(NSUInteger)stackSize
            qualityOfService:(NSQualityOfService)qualityOfService {
    self = [super init];
    if (self) {
        _name = [name copy];
        _stackSize = stackSize;
        _qualityOfService = qualityOfService;
        _running = NO;
    }
    return self;
}

#pragma mark - Public Methods
- (void)executeTaskWithBlock:(void (^)(void))block {
    [self executeTaskWithBlock:block waitUntilDone:NO];
}

- (void)executeTaskWithBlock:(void (^)(void))block waitUntilDone:(BOOL)wait {
    if (!self.isRunning) { return; }
    [self performSelector:@selector(_executeTaskWithBlock:) onThread:_thread withObject:block waitUntilDone:wait];
}

- (void)start {
    if (self.isRunning) { return; }
    _running = YES;
    
    PDThreadLaunchAction *action = [PDThreadLaunchAction new];
    _thread = [[NSThread alloc] initWithTarget:action selector:@selector(run:) object:nil];
    _thread.name = _name;
    _thread.stackSize = _stackSize;
    _thread.qualityOfService = _qualityOfService;
    [_thread start];
}

- (void)stop {
    if (!self.isRunning) { return; }
    _running = NO;
    
    [self performSelector:@selector(_stop) onThread:_thread withObject:nil waitUntilDone:YES];
}

#pragma mark - Private Methods
- (void)_executeTaskWithBlock:(void (^)(void))block {
    !block ?: block();
}

- (void)_stop {
    CFRunLoopRef rl = CFRunLoopGetCurrent();
    CFRunLoopStop(rl);
    _thread = nil;
}

#pragma mark - Getter Methods
- (NSMutableDictionary *)threadDictionary {
    return _thread.threadDictionary;
}

@end
