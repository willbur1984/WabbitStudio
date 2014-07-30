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
#import "NSBundle+WCExtensions.h"
#import "WCDebugging.h"

static NSString *const kWCPreferencesWindowControllerUserDefaultsKeySelectedViewControllerIdentifier = @"kWCPreferencesWindowControllerUserDefaultsKeySelectedViewControllerIdentifier";

static WCPreferencesWindowController *kCurrentPreferencesWindowController;

@interface WCPreferencesWindowController () <NSToolbarDelegate>
@property (readwrite,copy,nonatomic) NSArray *viewControllerClasses;
@property (readwrite,strong,nonatomic) NSViewController<WCPreferencesViewController> *selectedViewController;

- (NSArray *)_toolbarItemIdentifiers;
- (Class)_viewControllerClassForPreferencesIdentifier:(NSString *)preferencesIdentifier;
- (Class)_initialViewControllerClass;
- (NSRect)_windowFrameForViewController:(NSViewController *)viewController;
@end

@implementation WCPreferencesWindowController
#pragma mark *** Subclass Overrides ***
- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:[NSString stringWithFormat:@"%@.preferences.toolbar",[NSBundle mainBundle].WC_bundleIdentifier]];
    
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
    
    [self setSelectedViewController:[[[self _initialViewControllerClass] alloc] init]];
}

- (void)showWindow:(id)sender {
    [self.window center];
    
    [super showWindow:sender];
}
#pragma mark NSToolbarDelegate
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [self _toolbarItemIdentifiers];
}
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [self _toolbarItemIdentifiers];
}
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    return [self _toolbarItemIdentifiers];
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *retval = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    id<WCPreferencesViewController> viewControllerClass = (id<WCPreferencesViewController>)[self _viewControllerClassForPreferencesIdentifier:itemIdentifier];
    
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
        return kCurrentPreferencesWindowController;
    
    NSParameterAssert(viewControllerClasses);
    
    [self setViewControllerClasses:viewControllerClasses];
    
    kCurrentPreferencesWindowController = self;
    
    return self;
}
#pragma mark Properties
- (void)setSelectedViewController:(NSViewController<WCPreferencesViewController> *)selectedViewController {
    if ([_selectedViewController isEqual:selectedViewController])
        return;
    
    if (self.selectedViewController) {
        NSViewController<WCPreferencesViewController> *oldViewController = self.selectedViewController;
        
        _selectedViewController = selectedViewController;
        
        [self.window.contentView addSubview:selectedViewController.view positioned:NSWindowBelow relativeTo:oldViewController.view];
        
        [selectedViewController.view setAlphaValue:0.0];
        
        @weakify(self);
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            @strongify(self);
            
            [self.window.animator setFrame:[self _windowFrameForViewController:selectedViewController] display:NO];
            
            [oldViewController.view.animator setAlphaValue:0.0];
            [selectedViewController.view.animator setAlphaValue:1.0];
        } completionHandler:^{
            [oldViewController.view removeFromSuperviewWithoutNeedingDisplay];
        }];
    }
    else {
        _selectedViewController = selectedViewController;
        
        [self.window.contentView addSubview:selectedViewController.view];
        [self.window setFrame:[self _windowFrameForViewController:selectedViewController] display:NO];
    }
    
    [self.window.toolbar setSelectedItemIdentifier:[selectedViewController.class preferencesIdentifier]];
}
#pragma mark *** Private Methods ***
- (NSArray *)_toolbarItemIdentifiers; {
    return [self.viewControllerClasses bk_map:^id(id<WCPreferencesViewController> value) {
        return [value preferencesIdentifier];
    }];
}
- (Class)_viewControllerClassForPreferencesIdentifier:(NSString *)preferencesIdentifier; {
    return [self.viewControllerClasses bk_match:^BOOL(id<WCPreferencesViewController> value) {
        return [[value preferencesIdentifier] isEqualToString:preferencesIdentifier];
    }];
}
- (Class)_initialViewControllerClass; {
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:kWCPreferencesWindowControllerUserDefaultsKeySelectedViewControllerIdentifier];
    Class retval = [self _viewControllerClassForPreferencesIdentifier:identifier];
    
    return (retval) ?: self.viewControllerClasses.firstObject;
}
- (NSRect)_windowFrameForViewController:(NSViewController *)viewController; {
    NSRect retval = self.window.frame;
    NSRect contentRect = [self.window contentRectForFrameRect:retval];
    CGFloat windowTitleAndToolbarHeight = NSHeight(retval) - NSHeight(contentRect);
    
    retval.size.height = NSHeight(viewController.view.frame) + windowTitleAndToolbarHeight;
    retval.size.width = NSWidth(viewController.view.frame);
    retval.origin.y = NSMaxY(self.window.frame) - NSHeight(retval);
    
    return retval;
}
#pragma mark Actions
- (IBAction)_toolbarItemAction:(NSToolbarItem *)sender {
    Class viewControllerClass = [self _viewControllerClassForPreferencesIdentifier:sender.itemIdentifier];
    
    [self setSelectedViewController:[[viewControllerClass alloc] init]];
}

@end
