//
//  WCDocumentViewController.m
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

#import "WCDocumentViewController.h"
#import <WCEdit/WCEdit.h>
#import "WCSplitViewController.h"

@interface WCDocumentViewController ()
@property (weak,nonatomic) WCFile *file;

@property (strong,nonatomic) WCBaseViewController *contentViewController;
@end

@implementation WCDocumentViewController

- (BOOL)respondsToSelector:(SEL)aSelector {
    return ([self.contentViewController respondsToSelector:aSelector] ||
            [super respondsToSelector:aSelector]);
}
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.contentViewController respondsToSelector:aSelector])
        return self.contentViewController;
    return nil;
}

- (id)supplementalTargetForAction:(SEL)action sender:(id)sender {
    if ([self.contentViewController respondsToSelector:action])
        return self.contentViewController;
    return [super supplementalTargetForAction:action sender:sender];
}

- (void)loadView {
    [super loadView];
    
    if ([self.file isKindOfClass:[WCPlainTextFile class]]) {
        [self setContentViewController:[[WCSplitViewController alloc] initWithPlainTextFile:(WCPlainTextFile *)self.file]];
        [self.view addSubview:self.contentViewController.view];
        [self.contentViewController.view setFrame:self.view.bounds];
    }
}

- (instancetype)initWithFile:(WCFile *)file; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(file);
    
    [self setFile:file];
    
    return self;
}

@end
