//
//  WCFindOptionsViewController.m
//  WCEdit
//
//  Created by William Towe on 8/10/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCFindOptionsViewController.h"
#import "WCEditFunctions.h"
#import "WCTextFinderOptions.h"
#import <ReactiveCocoa/EXTKeyPathCoding.h>

@interface WCFindOptionsViewController ()
@property (weak,nonatomic) IBOutlet NSTextField *titleLabel;
@property (weak,nonatomic) IBOutlet NSTextField *matchingStyleLabel;
@property (weak,nonatomic) IBOutlet NSPopUpButton *matchingStylePopUpButton;
@property (weak,nonatomic) IBOutlet NSTextField *matchingTypeLabel;
@property (weak,nonatomic) IBOutlet NSPopUpButton *matchingTypePopUpButton;
@property (weak,nonatomic) IBOutlet NSButton *matchCaseCheckboxButton;
@property (weak,nonatomic) IBOutlet NSButton *wrapCheckboxButton;

@property (strong,nonatomic) WCTextFinderOptions *textFinderOptions;
@end

@implementation WCFindOptionsViewController
#pragma mark *** Subclass Overrides ***
- (NSBundle *)nibBundle {
    return WCEditBundle();
}

- (void)loadView {
    [super loadView];
    
    [self.titleLabel setStringValue:NSLocalizedString(@"Find Options", @"find options view title label")];
    [self.matchingStyleLabel setStringValue:NSLocalizedString(@"Matching Style", @"find options view matching style label")];
    [self.matchingStylePopUpButton setMenu:({
        NSMenu *retval = [[NSMenu alloc] initWithTitle:@""];
        
        for (NSUInteger i=0; i<=WCTextFinderOptionsMatchingStyleRegularExpression; i++) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[WCTextFinderOptions localizedStringForMatchingStyle:i] action:@selector(_matchingStyleAction:) keyEquivalent:@""];
            
            [item setTarget:self];
            [item setTag:i];
            
            [retval addItem:item];
        }
        
        retval;
    })];
    [self.matchingTypeLabel setStringValue:NSLocalizedString(@"Matching Type", @"find options view matching type label")];
    [self.matchingTypePopUpButton setMenu:({
        NSMenu *retval = [[NSMenu alloc] initWithTitle:@""];
        
        for (NSUInteger i=0; i<=WCTextFinderOptionsMatchingTypeEndsWith; i++) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[WCTextFinderOptions localizedStringForMatchingType:i] action:@selector(_matchingTypeAction:) keyEquivalent:@""];
            
            [item setTarget:self];
            [item setTag:i];
            
            [retval addItem:item];
        }
        
        retval;
    })];
    [self.matchCaseCheckboxButton setTitle:NSLocalizedString(@"Match Case", @"find options view match case checkbox button title")];
    [self.wrapCheckboxButton setTitle:NSLocalizedString(@"Wrap", @"find options view wrap checkbox button title")];
    
    [self.matchingStylePopUpButton bind:NSSelectedTagBinding toObject:self.textFinderOptions withKeyPath:@keypath(self.textFinderOptions,matchingStyle) options:nil];
    [self.matchingTypePopUpButton bind:NSSelectedTagBinding toObject:self.textFinderOptions withKeyPath:@keypath(self.textFinderOptions,matchingType) options:nil];
    [self.matchCaseCheckboxButton bind:NSValueBinding toObject:self.textFinderOptions withKeyPath:@keypath(self.textFinderOptions,matchCase) options:nil];
    [self.wrapCheckboxButton bind:NSValueBinding toObject:self.textFinderOptions withKeyPath:@keypath(self.textFinderOptions,wrap) options:nil];
}
#pragma mark *** Public Methods ***
- (instancetype)initWithTextFinderOptions:(WCTextFinderOptions *)textFinderOptions; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(textFinderOptions);
    
    [self setTextFinderOptions:textFinderOptions];
    
    return self;
}

- (IBAction)_matchingStyleAction:(id)sender {
    
}
- (IBAction)_matchingTypeAction:(id)sender {
    
}

@end
