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
@property (weak,nonatomic) NSTrackingArea *bookmarksTrackingArea;
@property (weak,nonatomic) RACDisposable *notificationCenterDisposable;

@property (assign,nonatomic) NSPoint mouseDownPoint;
@property (assign,nonatomic) NSPoint mouseMovedPoint;

- (NSRect)_bookmarkRectForLineNumber:(NSUInteger)lineNumber;
@end

@implementation WCBookmarksRulerView
#pragma mark *** Subclass Overrides ***
#pragma mark NSResponder
- (void)mouseEntered:(NSEvent *)theEvent {
    if (theEvent.trackingArea == self.bookmarksTrackingArea) {
        [self setMouseMovedPoint:[self convertPoint:theEvent.locationInWindow fromView:nil]];
        
        [self setNeedsDisplayInRect:[self bookmarksRectForRect:self.bounds]];
    }
}
- (void)mouseExited:(NSEvent *)theEvent {
    if (theEvent.trackingArea == self.bookmarksTrackingArea) {
        [self setMouseMovedPoint:NSMakePoint(CGFLOAT_MAX, CGFLOAT_MAX)];
        
        [self setNeedsDisplayInRect:[self bookmarksRectForRect:self.bounds]];
    }
}
- (void)mouseMoved:(NSEvent *)theEvent {
    [self setMouseMovedPoint:[self convertPoint:theEvent.locationInWindow fromView:nil]];
    
    [self setNeedsDisplayInRect:[self bookmarksRectForRect:self.bounds]];
}
- (void)mouseDown:(NSEvent *)theEvent {
    [self setMouseDownPoint:[self convertPoint:theEvent.locationInWindow fromView:nil]];
    
    [self setNeedsDisplayInRect:[self bookmarksRectForRect:self.bounds]];
}
- (void)mouseUp:(NSEvent *)theEvent {
    NSUInteger mouseDownLineNumber = [self lineNumberForPoint:self.mouseDownPoint];
    NSUInteger mouseUpLineNumber = [self lineNumberForPoint:[self convertPoint:theEvent.locationInWindow fromView:nil]];
    
    if (mouseDownLineNumber == mouseUpLineNumber) {
        NSRange range = NSMakeRange([self.lineNumbersDataSource lineStartIndexForLineNumber:mouseDownLineNumber], 0);
        id<WCBookmark> bookmark = [self bookmarkForPoint:self.mouseDownPoint];
        
        if (bookmark)
            [self.bookmarksDataSource removeBookmark:bookmark];
        else
            [self.bookmarksDataSource addBookmarkWithRange:range];
    }
    
    [self setMouseDownPoint:NSMakePoint(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    [self setNeedsDisplayInRect:[self bookmarksRectForRect:self.bounds]];
}
#pragma mark NSView
- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    [self removeTrackingArea:self.bookmarksTrackingArea];
    
    NSTrackingArea *bookmarksTrackingArea = [[NSTrackingArea alloc] initWithRect:[self bookmarksRectForRect:self.bounds] options:NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveInKeyWindow owner:self userInfo:nil];
    
    [self addTrackingArea:bookmarksTrackingArea];
    
    [self setBookmarksTrackingArea:bookmarksTrackingArea];
}
#pragma mark NSRulerView
static CGFloat const kBookmarkWidth = 15.0;

- (CGFloat)requiredThickness {
    return [super requiredThickness] + kBookmarkWidth;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
    [super drawHashMarksAndLabelsInRect:rect];
    
    [self drawBookmarksInRect:rect];
}
#pragma mark WCLineNumbersRulerView
- (instancetype)initWithScrollView:(NSScrollView *)scrollView lineNumbersDataSource:(id<WCLineNumbersDataSource>)lineNumbersDataSource {
    if (!(self = [super initWithScrollView:scrollView lineNumbersDataSource:lineNumbersDataSource]))
        return nil;
    
    [self setMouseDownPoint:NSMakePoint(CGFLOAT_MAX, CGFLOAT_MAX)];
    [self setMouseMovedPoint:NSMakePoint(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    return self;
}
#pragma mark *** Public Methods ***
- (NSRect)bookmarksRectForRect:(NSRect)rect; {
    return NSMakeRect(NSMinX(rect), NSMinY(rect), kBookmarkWidth, NSHeight(rect));
}

- (id<WCBookmark>)bookmarkForPoint:(NSPoint)point; {
    NSUInteger lineNumber = [self lineNumberForPoint:point];
    id<WCBookmark> retval = [self.bookmarksDataSource sortedBookmarksInInclusiveRange:NSMakeRange([self.lineNumbersDataSource lineStartIndexForLineNumber:lineNumber], 0)].firstObject;
    
    return retval;
}

- (void)drawBookmarksInRect:(NSRect)rect {
    if (!self.bookmarksDataSource)
        return;
    else if (!NSIntersectsRect([self bookmarksRectForRect:self.bounds], rect))
        return;
    
    NSArray *viewModels = [[self.bookmarksDataSource sortedBookmarksInInclusiveRange:[self.textView WC_visibleRange]] bk_map:^id(id<WCBookmark> obj) {
        return [[WCBookmarkViewModel alloc] initWithBookmark:obj];
    }];
    
    NSUInteger mouseMovedLineNumber = [self lineNumberForPoint:self.mouseMovedPoint];
    
    for (WCBookmarkViewModel *viewModel in viewModels) {
        NSUInteger lineNumber = [self.lineNumbersDataSource lineNumberForRange:[viewModel.bookmark rangeValue]];
        
        if (mouseMovedLineNumber == lineNumber)
            [viewModel setState:WCBookmarkViewModelStateHoverRemove];
        
        [viewModel drawInRect:[self _bookmarkRectForLineNumber:lineNumber]];
    }
    
    if (mouseMovedLineNumber != NSNotFound) {
        NSUInteger mouseDownLineNumber = [self lineNumberForPoint:self.mouseDownPoint];
        WCBookmarkViewModel *viewModel = [[WCBookmarkViewModel alloc] initWithBookmark:nil];
        
        if (mouseMovedLineNumber == mouseDownLineNumber)
            [viewModel setState:WCBookmarkViewModelStateNone];
        else
            [viewModel setState:WCBookmarkViewModelStateHoverAdd];
        
        [viewModel drawInRect:[self _bookmarkRectForLineNumber:mouseMovedLineNumber]];
    }
}
#pragma mark Properties
- (void)setBookmarksDataSource:(id<WCBookmarksDataSource>)bookmarksDataSource {
    _bookmarksDataSource = bookmarksDataSource;
    
    [self.notificationCenterDisposable dispose];
    
    if (self.bookmarksDataSource) {
        @weakify(self);
        
        [self setNotificationCenterDisposable:
         [[[RACSignal merge:@[[[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidAddBookmark object:self.bookmarksDataSource],
                              [[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidRemoveBookmark object:self.bookmarksDataSource],
                              [[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidRemoveBookmarks object:self.bookmarksDataSource]]]
           takeUntil:[self rac_willDeallocSignal]]
          subscribeNext:^(id _) {
              @strongify(self);
             
              [self setNeedsDisplayInRect:[self bookmarksRectForRect:self.bounds]];
          }]];
    }
}
#pragma mark *** Private Methods ***
- (NSRect)_bookmarkRectForLineNumber:(NSUInteger)lineNumber; {
    NSRect bookmarksRect = [self bookmarksRectForRect:self.bounds];
    NSUInteger lineStartIndex = [self.lineNumbersDataSource lineStartIndexForLineNumber:lineNumber];
    NSUInteger glyphIndex = [self.textView.layoutManager glyphIndexForCharacterAtIndex:lineStartIndex];
    NSRect lineRect = [self.textView.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL withoutAdditionalLayout:YES];
    NSRect retval = NSInsetRect(NSMakeRect(NSMinX(self.bounds), [self convertPoint:lineRect.origin fromView:self.clientView].y, NSWidth(bookmarksRect), NSHeight(lineRect)), 0.0, 2.0);
    
    return retval;
}

@end
