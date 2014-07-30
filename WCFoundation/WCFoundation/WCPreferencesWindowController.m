//
//  WCPreferencesWindowController.m
//  WCFoundation
//
//  Created by William Towe on 7/30/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCPreferencesWindowController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString *const kWCPreferencesWindowControllerUserDefaultsKeySelectedViewControllerIdentifier = @"kWCPreferencesWindowControllerUserDefaultsKeySelectedViewControllerIdentifier";

@interface WCPreferencesWindowController () <NSToolbarDelegate>
@property (readwrite,copy,nonatomic) NSArray *viewControllerClasses;
@property (readwrite,strong,nonatomic) NSViewController<WCPreferencesViewController> *selectedViewController;

@end

@implementation WCPreferencesWindowController
#pragma mark *** Subclass Overrides ***
- (void)windowDidLoad {
    [super windowDidLoad];
    
    
}
#pragma mark NSToolbarDelegate
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [self.viewControllerClasses.rac_sequence map:^id(id<WCPreferencesViewController> value) {
        return [value preferencesIdentifier];
    }].array;
}
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [self.viewControllerClasses.rac_sequence map:^id(id<WCPreferencesViewController> value) {
        return [value preferencesIdentifier];
    }].array;
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *retval = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    
    
    return retval;
}

#pragma mark *** Public Methods ***
- (instancetype)initWithViewControllerClasses:(NSArray *)viewControllerClasses; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(viewControllerClasses);
    
    [self setViewControllerClasses:viewControllerClasses];
    
    return self;
}

@end
