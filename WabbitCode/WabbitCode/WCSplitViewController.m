//
//  WCSplitViewController.m
//  WabbitCode
//
//  Created by William Towe on 8/6/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSplitViewController.h"
#import <WCFoundation/WCFoundation.h>
#import <WCEdit/WCEdit.h>
#import "WCPreferencesTextEditingViewController.h"
#import "MAKVONotificationCenter.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>
#import <BlocksKit/BlocksKit.h>
#import "RBSplitView.h"

typedef NS_ENUM(NSInteger, WCSplitViewControllerOrientation) {
    WCSplitViewControllerOrientationVertical,
    WCSplitViewControllerOrientationHorizontal
};

@interface WCSplitViewController () <RBSplitViewDelegate>
@property (weak,nonatomic) WCPlainTextFile *plainTextFile;

@property (strong,nonatomic) RBSplitView *splitView;
@property (copy,nonatomic) NSArray *viewControllers;

- (void)_configurePlainTextViewController:(WCPlainTextViewController *)plainTextViewController;
- (void)_createSplitViewIfNecessary;
- (void)_destroySplitViewIfNecessary;
- (void)_addSplitWithOrientation:(WCSplitViewControllerOrientation)orientation;
- (void)_addViewController:(WCPlainTextViewController *)viewController;
- (void)_removeViewController:(WCPlainTextViewController *)viewController;
@end

@implementation WCSplitViewController
#pragma mark *** Subclass Overrides ***
- (void)loadView {
    [super loadView];
    
    [self _addViewController:[[WCPlainTextViewController alloc] initWithPlainTextFile:self.plainTextFile]];
    [[self.viewControllers.firstObject view] setFrame:self.view.bounds];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.action == @selector(closeSplitAction:)) {
        return (self.viewControllers.count > 1);
    }
    return YES;
}
#pragma mark RBSplitViewDelegate
- (BOOL)splitView:(RBSplitView *)sender canCollapse:(RBSplitSubview *)subview {
    return NO;
}
#pragma mark *** Public Methods ***
- (instancetype)initWithPlainTextFile:(WCPlainTextFile *)plainTextFile; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(plainTextFile);
    
    [self setPlainTextFile:plainTextFile];
    
    return self;
}
#pragma mark Actions
- (IBAction)newVerticalSplitAction:(id)sender; {
    [self _addSplitWithOrientation:WCSplitViewControllerOrientationVertical];
}
- (IBAction)newHorizontalSplitAction:(id)sender; {
    [self _addSplitWithOrientation:WCSplitViewControllerOrientationHorizontal];
}
- (IBAction)closeSplitAction:(id)sender; {
    NSTextView *textView = [self.plainTextFile.textStorage WC_firstResponderTextView];
    WCPlainTextViewController *viewController = [self.viewControllers bk_match:^BOOL(WCPlainTextViewController *obj) {
        return [obj.textView isEqual:textView];
    }];
    
    [self _removeViewController:viewController];
    [self _destroySplitViewIfNecessary];
}
#pragma mark *** Private Methods ***
- (void)_configurePlainTextViewController:(WCPlainTextViewController *)viewController; {
    [viewController.textView setHighlightCurrentLineColor:[NSColor colorWithRed:1.0 green:1.0 blue:0.901960784 alpha:1.0]];
    
    [viewController.textView setAutoPairCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"'\"`([{"]];
    [viewController.textView setAutoPairLeftCharactersToRightCharacters:@{@('('): @(')'),
                                                                          @('['): @(']'),
                                                                          @('{'): @('}')}];
    
    NSArray *userDefaultsKeyPaths = @[[@[@keypath(NSUserDefaultsController.new,values),WCPreferencesTextEditingViewControllerUserDefaultsKeyHighlightCurrentLine] WC_keypath],
                                      [@[@keypath(NSUserDefaultsController.new,values),WCPreferencesTextEditingViewControllerUserDefaultsKeyAutoPairCharacters] WC_keypath],
                                      [@[@keypath(NSUserDefaultsController.new,values),WCPreferencesTextEditingViewControllerUserDefaultsKeyWrapSelectedTextWithPairCharacters] WC_keypath]];
    
    @weakify(viewController);
    
    [[NSUserDefaultsController sharedUserDefaultsController] addObservationKeyPath:userDefaultsKeyPaths options:NSKeyValueObservingOptionInitial block:^(MAKVONotification *notification) {
        @strongify(viewController);
        
        if ([notification.keyPath hasSuffix:WCPreferencesTextEditingViewControllerUserDefaultsKeyHighlightCurrentLine])
            [viewController.textView setHighlightCurrentLine:[[NSUserDefaults standardUserDefaults] boolForKey:WCPreferencesTextEditingViewControllerUserDefaultsKeyHighlightCurrentLine]];
        else if ([notification.keyPath hasSuffix:WCPreferencesTextEditingViewControllerUserDefaultsKeyAutoPairCharacters])
            [viewController.textView setAutoPairCharacters:[[NSUserDefaults standardUserDefaults] boolForKey:WCPreferencesTextEditingViewControllerUserDefaultsKeyAutoPairCharacters]];
        else if ([notification.keyPath hasSuffix:WCPreferencesTextEditingViewControllerUserDefaultsKeyWrapSelectedTextWithPairCharacters])
            [viewController.textView setWrapSelectedTextWithPairCharacters:[[NSUserDefaults standardUserDefaults] boolForKey:WCPreferencesTextEditingViewControllerUserDefaultsKeyWrapSelectedTextWithPairCharacters]];
    }];
}
- (void)_createSplitViewIfNecessary; {
    if (self.splitView)
        return;
    
    [self setSplitView:[[RBSplitView alloc] initWithFrame:self.view.bounds]];
    [self.splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self.splitView setBackground:[NSColor darkGrayColor]];
    [self.splitView setDivider:({
        NSImage *retval = [[NSImage alloc] initWithSize:NSMakeSize(10.0, 10.0)];
        
        [retval lockFocus];
        
        [[NSColor whiteColor] setFill];
        [[NSBezierPath bezierPathWithOvalInRect:NSInsetRect(NSMakeRect(0, 0, retval.size.width, retval.size.height), 2.0, 2.0)] fill];
        
        [retval unlockFocus];
        
        retval;
    })];
    [self.splitView setDelegate:self];
    [self.view addSubview:self.splitView];
    
    WCPlainTextViewController *viewController = self.viewControllers.firstObject;
    RBSplitSubview *subview = [[RBSplitSubview alloc] initWithFrame:viewController.view.frame];
    
    [subview setIdentifier:[NSString stringWithFormat:@"%p",viewController]];
    [subview addSubview:viewController.view];
    
    [self.splitView addSubview:subview];
}
- (void)_destroySplitViewIfNecessary; {
    if (self.splitView && self.viewControllers.count > 1)
        return;
    
    [self.splitView removeFromSuperview];
    [self setSplitView:nil];
    
    [self.view addSubview:[self.viewControllers.firstObject view]];
    [[self.viewControllers.firstObject view] setFrame:self.view.bounds];
}
- (void)_addSplitWithOrientation:(WCSplitViewControllerOrientation)orientation; {
    [self _createSplitViewIfNecessary];
    
    [self.splitView setVertical:(orientation == WCSplitViewControllerOrientationVertical)];
    
    [self _addViewController:[[WCPlainTextViewController alloc] initWithPlainTextFile:self.plainTextFile]];
}
- (void)_addViewController:(WCPlainTextViewController *)viewController; {
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    
    [viewControllers addObject:viewController];
    
    if (self.splitView) {
        RBSplitSubview *subview = [[RBSplitSubview alloc] initWithFrame:viewController.view.frame];
        
        [subview setIdentifier:[NSString stringWithFormat:@"%p",viewController]];
        [subview addSubview:viewController.view];
        
        [self.splitView addSubview:subview];
    }
    else
        [self.view addSubview:viewController.view];
    
    [self _configurePlainTextViewController:viewController];
    
    CGFloat totalAmount = (self.splitView.isVertical) ? NSWidth(self.splitView.frame) : NSHeight(self.splitView.frame);
    CGFloat amount = floor((totalAmount - (self.splitView.dividerThickness * (self.splitView.numberOfSubviews - 2))) / self.splitView.numberOfSubviews);
    CGFloat minAmount = floor(amount * 0.33);
    
    for (RBSplitSubview *subview in self.splitView.subviews) {
        [subview setMinDimension:minAmount andMaxDimension:0.0];
        [subview setDimension:amount];
    }
    
    [viewController.textView WC_makeFirstResponder];
    
    [self setViewControllers:viewControllers];
}
- (void)_removeViewController:(WCPlainTextViewController *)viewController; {
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    
    [viewControllers removeObject:viewController];
    
    RBSplitSubview *subview = [self.splitView subviewWithIdentifier:[NSString stringWithFormat:@"%p",viewController]];
    
    [subview removeFromSuperview];
    
    [viewController.textView.textStorage removeLayoutManager:viewController.textView.layoutManager];
    
    [[(WCPlainTextViewController *)viewControllers.lastObject textView] WC_makeFirstResponder];
    
    [self setViewControllers:viewControllers];
}

@end
