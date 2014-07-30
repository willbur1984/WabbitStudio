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
#import <ReactiveCocoa/EXTScope.h>
#import <BlocksKit/BlocksKit.h>

static NSString *const kWCPreferencesWindowControllerUserDefaultsKeySelectedViewControllerIdentifier = @"kWCPreferencesWindowControllerUserDefaultsKeySelectedViewControllerIdentifier";

static WCPreferencesWindowController *kCurrentPreferencesWindowController;

@interface WCPreferencesWindowController () <NSToolbarDelegate>
@property (readwrite,copy,nonatomic) NSArray *viewControllerClasses;
@property (readwrite,strong,nonatomic) NSViewController<WCPreferencesViewController> *selectedViewController;

@end

@implementation WCPreferencesWindowController
#pragma mark *** Subclass Overrides ***
- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:nil];
    
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:NO];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode:NSToolbarSizeModeRegular];
    [toolbar setDelegate:self];
    
    [self.window setToolbar:toolbar];
    
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:NSWindowWillCloseNotification object:self.window]
      take:1]
     subscribeNext:^(id _) {
         kCurrentPreferencesWindowController = nil;
    }];
}

- (void)showWindow:(id)sender {
    [self.window center];
    
    [super showWindow:sender];
}
#pragma mark NSToolbarDelegate
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [self.viewControllerClasses bk_map:^id(id<WCPreferencesViewController> value) {
        return [value preferencesIdentifier];
    }];
}
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [self.viewControllerClasses bk_map:^id(id<WCPreferencesViewController> value) {
        return [value preferencesIdentifier];
    }];
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *retval = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    id<WCPreferencesViewController> viewControllerClass = [self.viewControllerClasses bk_match:^BOOL(id<WCPreferencesViewController> value) {
        return [[value preferencesIdentifier] isEqualToString:itemIdentifier];
    }];
    
    [retval setLabel:[viewControllerClass preferencesName]];
    [retval setImage:[viewControllerClass preferencesImage]];
    [retval setTarget:self];
    [retval setAction:@selector(_toolbarItemAction:)];
    
    if ([viewControllerClass respondsToSelector:@selector(preferencesToolTip)])
        [retval setToolTip:[viewControllerClass preferencesToolTip]];
    
    return retval;
}

#pragma mark *** Public Methods ***
- (instancetype)initWithViewControllerClasses:(NSArray *)viewControllerClasses; {
    if (!(self = [super init]))
        return nil;
    
    if (kCurrentPreferencesWindowController)
        return nil;
    
    NSParameterAssert(viewControllerClasses);
    
    [self setViewControllerClasses:viewControllerClasses];
    
    kCurrentPreferencesWindowController = self;
    
    return self;
}
#pragma mark *** Private Methods ***
#pragma mark Actions
- (IBAction)_toolbarItemAction:(NSToolbarItem *)sender {
    
}

@end
