//
//  WCFile.m
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCFile.h"
#import "WCDebugging.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>

@interface WCFile ()
@property (readwrite,copy,nonatomic) NSURL *fileURL;
@property (readwrite,copy,nonatomic) NSString *UTI;

@property (strong,nonatomic) dispatch_source_t fileSource;

- (void)_startMonitoringFileSource;
- (void)_stopMonitoringFileSource;
@end

@implementation WCFile
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [self _stopMonitoringFileSource];
}
#pragma mark *** Public Methods ***
- (instancetype)initWithFileURL:(NSURL *)fileURL UTI:(NSString *)UTI; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(UTI);
    
    [self setFileURL:fileURL];
    [self setUTI:UTI];
    
    @weakify(self);
    
    [[[RACObserve(self, fileURL)
       distinctUntilChanged]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id _) {
         @strongify(self);

         [self _startMonitoringFileSource];
    }];
    
    return self;
}

#pragma mark *** Private Methods ***
- (void)_startMonitoringFileSource; {
    [self _stopMonitoringFileSource];
    
    if (!self.fileURL)
        return;
    
    int fileDescriptor = open(self.fileURL.path.fileSystemRepresentation, O_EVTONLY);
    
    [self setFileSource:dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor, DISPATCH_VNODE_DELETE|DISPATCH_VNODE_RENAME|DISPATCH_VNODE_WRITE|DISPATCH_VNODE_EXTEND|DISPATCH_VNODE_ATTRIB, dispatch_get_main_queue())];
    
    @weakify(self);
    
    dispatch_source_set_event_handler(self.fileSource, ^{
        @strongify(self);
        
        unsigned long flags = dispatch_source_get_data(self.fileSource);
        
        WCLogObject(@(flags));
        
        if (flags & DISPATCH_VNODE_DELETE) {
            [self _startMonitoringFileSource];
        }
    });
    
    dispatch_source_set_cancel_handler(self.fileSource, ^{
        close(fileDescriptor);
    });
    
    dispatch_resume(self.fileSource);
}
- (void)_stopMonitoringFileSource; {
    if (!self.fileURL)
        return;
    
    if (!self.fileSource)
        return;
    
    dispatch_source_cancel(self.fileSource);
}

@end
