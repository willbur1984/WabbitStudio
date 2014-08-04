//
//  WCBookmarksRulerView.m
//  WCEdit
//
//  Created by William Towe on 8/3/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCBookmarksRulerView.h"
#import "NSTextView+WCExtensions.h"
#import <BlocksKit/BlocksKit.h>
#import "WCBookmarkViewModel.h"
#import <WCFoundation/WCFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>

@interface WCBookmarksRulerView ()
@property (weak,nonatomic) RACDisposable *notificationCenterDisposable;
@end

@implementation WCBookmarksRulerView

static CGFloat const kBookmarkWidth = 15.0;

- (CGFloat)requiredThickness {
    return [super requiredThickness] + kBookmarkWidth;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
    [super drawHashMarksAndLabelsInRect:rect];
    
    [self drawBookmarksInRect:rect];
}

- (NSRect)bookmarksRectForRect:(NSRect)rect; {
    return NSMakeRect(NSMinX(rect), NSMinY(rect), kBookmarkWidth, NSHeight(rect));
}

- (void)drawBookmarksInRect:(NSRect)rect {
    if (!self.bookmarksDataSource)
        return;
    
    NSArray *viewModels = [[self.bookmarksDataSource sortedBookmarksInInclusiveRange:[self.textView WC_visibleRange]] bk_map:^id(id<WCBookmark> obj) {
        return [[WCBookmarkViewModel alloc] initWithBookmark:obj];
    }];
    
    if (viewModels.count == 0)
        return;
    
    NSRect bookmarksRect = [self bookmarksRectForRect:rect];
    
    for (WCBookmarkViewModel *viewModel in viewModels) {
        NSRange range = [viewModel.bookmark rangeValue];
        NSUInteger lineNumber = [self.lineNumbersDataSource lineNumberForRange:range];
        NSUInteger lineStartIndex = [self.lineNumbersDataSource lineStartIndexForLineNumber:lineNumber];
        NSUInteger glyphIndex = [self.textView.layoutManager glyphIndexForCharacterAtIndex:lineStartIndex];
        NSRect lineRect = [self.textView.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL withoutAdditionalLayout:YES];
        NSRect bookmarkRect = NSInsetRect(NSMakeRect(NSMinX(self.bounds), [self convertPoint:lineRect.origin fromView:self.clientView].y, NSWidth(bookmarksRect), NSHeight(lineRect)), 0.0, 3.0);
        
        [viewModel drawInRect:bookmarkRect];
    }
}

- (void)setBookmarksDataSource:(id<WCBookmarksDataSource>)bookmarksDataSource {
    _bookmarksDataSource = bookmarksDataSource;
    
    [self.notificationCenterDisposable dispose];
    
    if (self.bookmarksDataSource) {
        @weakify(self);
        
        [self setNotificationCenterDisposable:
         [[[RACSignal merge:@[[[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidAddBookmark object:self.bookmarksDataSource],
                              [[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidRemoveBookmark object:self.bookmarksDataSource],
                              [[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidAddBookmarks object:self.bookmarksDataSource],
                              [[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidRemoveBookmarks object:self.bookmarksDataSource]]]
           takeUntil:[self rac_willDeallocSignal]]
          subscribeNext:^(id _) {
              @strongify(self);
             
              [self setNeedsDisplayInRect:self.visibleRect];
          }]];
    }
}

@end
