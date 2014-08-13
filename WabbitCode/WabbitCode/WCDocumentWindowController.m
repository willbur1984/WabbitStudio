//
//  WCDocumentWindowController.m
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

#import "WCDocumentWindowController.h"
#import <WCFoundation/WCFile.h>
#import "WCSplitViewController.h"

@interface WCDocumentWindowController () <NSWindowDelegate>
@property (strong,nonatomic) WCSplitViewController *splitViewController;

@property (weak,nonatomic) WCFile *file;
@end

@implementation WCDocumentWindowController
#pragma mark *** Subclass Overrides ***
- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setDelegate:self];
    
    [self setSplitViewController:[[WCSplitViewController alloc] initWithPlainTextFile:(WCPlainTextFile *)self.file]];
    [self.window setContentView:self.splitViewController.view];
}
#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    
}
#pragma mark *** Public Methods ***
- (instancetype)initWithFile:(WCFile *)file; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(file);
    
    [self setFile:file];
    
    return self;
}

@end
