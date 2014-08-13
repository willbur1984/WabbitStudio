//
//  WCTextFinder.m
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

#import "WCTextFinder.h"
#import <WCFoundation/WCFoundation.h>
#import "WCFindBarViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>
#import "WCTextFinderOptions.h"

@interface WCTextFinder ()
@property (strong,nonatomic) WCFindBarViewController *findBarViewController;

@property (readwrite,strong,nonatomic) WCTextFinderOptions *options;

@property (readwrite,copy,nonatomic) NSIndexSet *matchRanges;

- (NSRange)_nextRangeDidWrap:(BOOL *)didWrap;
- (NSRange)_previousRangeDidWrap:(BOOL *)didWrap;
@end

@implementation WCTextFinder
#pragma mark *** Subclass Overrides ***
- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setOptions:[[WCTextFinderOptions alloc] init]];
    [self setFindBarViewController:[[WCFindBarViewController alloc] initWithTextFinder:self]];
    
    @weakify(self);
    
    RAC(self,matchRanges) = [[[[RACSignal combineLatest:@[RACObserve(self.findBarViewController, searchString),RACObserve(self.options, matchingType),RACObserve(self.options, matchCase),[[[self rac_signalForSelector:@selector(noteClientStringDidChange)] startWith:nil] throttle:0.5]]] map:^id(RACTuple *value) {
        @strongify(self);
        
        RACTupleUnpack(NSString *searchString, NSNumber *matchingType, NSNumber *matchCase) = value;
        
        return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            
            RACDisposable *disposable = [[RACDisposable alloc] init];
            NSMutableIndexSet *retval = [[NSMutableIndexSet alloc] init];

            if (searchString.length > 0) {
                __block NSString *string;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    
                    string = [[self.client string] copy];
                });
                
                NSRange searchRange = NSMakeRange(0, string.length);
                WCTextFinderOptionsMatchingType matchingTypeValue = matchingType.integerValue;
                NSStringCompareOptions options = NSLiteralSearch;
                
                if (!matchCase.boolValue)
                    options |= NSCaseInsensitiveSearch;
                
                CFLocaleRef localeRef = CFLocaleCopyCurrent();
                CFStringTokenizerRef tokenizerRef = CFStringTokenizerCreate(kCFAllocatorDefault, (__bridge CFStringRef)string, CFRangeMake(0, string.length), kCFStringTokenizerUnitWordBoundary, localeRef);
                CFRelease(localeRef);
                
                while (searchRange.location < string.length) {
                    if (disposable.isDisposed)
                        break;
                    
                    NSRange range = [string rangeOfString:searchString options:options range:searchRange];
                    
                    if (range.length == 0)
                        break;
                    
                    CFStringTokenizerGoToTokenAtIndex(tokenizerRef, range.location);
                    CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizerRef);
                    
                    switch (matchingTypeValue) {
                        case WCTextFinderOptionsMatchingTypeContains:
                            [retval addIndexesInRange:range];
                            break;
                        case WCTextFinderOptionsMatchingTypeStartsWith:
                            if (range.location == tokenRange.location &&
                                range.length < tokenRange.length) {
                                
                                [retval addIndexesInRange:range];
                            }
                            break;
                        case WCTextFinderOptionsMatchingTypeEndsWith:
                            if (NSMaxRange(range) == (tokenRange.location + tokenRange.length)) {
                                [retval addIndexesInRange:range];
                            }
                        case WCTextFinderOptionsMatchingTypeFullWord:
                            if (range.location == tokenRange.location &&
                                range.length == tokenRange.length) {
                                
                                [retval addIndexesInRange:range];
                            }
                        default:
                            break;
                    }
                    
                    searchRange = NSMakeRange(NSMaxRange(range), string.length - NSMaxRange(range));
                }
                
                CFRelease(tokenizerRef);
            }
            
            [subscriber sendNext:retval];
            [subscriber sendCompleted];
            
            return disposable;
        }] subscribeOn:[RACScheduler scheduler]];
    }] switchToLatest] deliverOn:[RACScheduler mainThreadScheduler]];
    
    return self;
}
#pragma mark *** Public Methods ***
+ (NSDictionary *)textFinderAttributes; {
    return @{NSBackgroundColorAttributeName: [[NSColor yellowColor] colorWithAlphaComponent:0.5],
             NSUnderlineColorAttributeName: [[NSColor orangeColor] colorWithAlphaComponent:0.6],
             NSUnderlineStyleAttributeName: @(NSUnderlineStyleThick|NSUnderlinePatternSolid)};
}

- (BOOL)validateAction:(NSTextFinderAction)action; {
    switch (action) {
        case NSTextFinderActionSetSearchString:
            return [self.client firstSelectedRange].length > 0;
        case NSTextFinderActionShowReplaceInterface:
        case NSTextFinderActionReplace:
        case NSTextFinderActionReplaceAll:
        case NSTextFinderActionReplaceAllInSelection:
        case NSTextFinderActionReplaceAndFind:
            return [self.client isEditable];
        default:
            return YES;
    }
}
- (void)performAction:(NSTextFinderAction)action; {
    switch (action) {
        case NSTextFinderActionShowFindInterface:
            [self.viewContainer setTextFinderViewVisible:YES];
            [self.findBarViewController.searchField becomeFirstResponder];
            break;
        case NSTextFinderActionHideFindInterface:
            [self.viewContainer setTextFinderViewVisible:NO];
            
            if ([self.viewContainer respondsToSelector:@selector(contentView)])
                [[self.viewContainer contentView] becomeFirstResponder];
            
            break;
        case NSTextFinderActionNextMatch: {
            NSRange range = [self _nextRangeDidWrap:NULL];
            
            if (range.length > 0) {
                [self.client setSelectedRanges:@[[NSValue valueWithRange:range]]];
                [self.client scrollRangeToVisible:range];
                
                if ([self.client respondsToSelector:@selector(showFindIndicatorForRange:)])
                    [self.client showFindIndicatorForRange:range];
            }
            else {
                NSBeep();
            }
        }
            break;
        case NSTextFinderActionPreviousMatch: {
            NSRange range = [self _previousRangeDidWrap:NULL];
            
            if (range.length > 0) {
                [self.client setSelectedRanges:@[[NSValue valueWithRange:range]]];
                [self.client scrollRangeToVisible:range];
                
                if ([self.client respondsToSelector:@selector(showFindIndicatorForRange:)])
                    [self.client showFindIndicatorForRange:range];
            }
            else {
                NSBeep();
            }
        }
            break;
        case NSTextFinderActionSetSearchString:
            [self.findBarViewController setSearchString:[[self.client string] substringWithRange:[self.client firstSelectedRange]]];
            break;
        default:
            break;
    }
}

- (void)noteClientStringDidChange; {
    [self setMatchRanges:nil];
}
#pragma mark Properties
- (void)setViewContainer:(id<WCTextFinderViewContainer>)viewContainer {
    if (self.viewContainer) {
        [self.viewContainer setTextFinderViewVisible:NO];
        [self.viewContainer setTextFinderView:nil];
    }
    
    _viewContainer = viewContainer;
    
    if (self.viewContainer) {
        [self.viewContainer setTextFinderView:self.findBarViewController.view];
    }
}
#pragma mark *** Private Methods ***
- (NSRange)_nextRangeDidWrap:(BOOL *)didWrap; {
    NSRange searchRange = NSMakeRange(NSMaxRange([self.client firstSelectedRange]), [self.client string].length - NSMaxRange([self.client firstSelectedRange]));
    NSStringCompareOptions options = NSLiteralSearch;
    
    if (!self.options.matchCase)
        options |= NSCaseInsensitiveSearch;
    
    NSRange range = [[self.client string] rangeOfString:self.findBarViewController.searchString options:options range:searchRange];
    
    if (range.length == 0 &&
        self.options.wrap) {
        
        searchRange = NSMakeRange(0, [self.client firstSelectedRange].location);
        range = [[self.client string] rangeOfString:self.findBarViewController.searchString options:options range:searchRange];
        
        if (range.length > 0 &&
            didWrap) {
            
            *didWrap = YES;
        }
    }
    
    return range;
}
- (NSRange)_previousRangeDidWrap:(BOOL *)didWrap; {
    NSRange searchRange = NSMakeRange(0, [self.client firstSelectedRange].location);
    NSStringCompareOptions options = NSLiteralSearch|NSBackwardsSearch;
    
    if (!self.options.matchCase)
        options |= NSCaseInsensitiveSearch;
    
    NSRange range = [[self.client string] rangeOfString:self.findBarViewController.searchString options:options range:searchRange];
    
    if (range.length == 0 &&
        self.options.wrap) {
        
        searchRange = NSMakeRange(NSMaxRange([self.client firstSelectedRange]), [self.client string].length - NSMaxRange([self.client firstSelectedRange]));
        range = [[self.client string] rangeOfString:self.findBarViewController.searchString options:options range:searchRange];
        
        if (range.length > 0 &&
            didWrap) {
            
            *didWrap = YES;
        }
    }
    
    return range;
}

@end
