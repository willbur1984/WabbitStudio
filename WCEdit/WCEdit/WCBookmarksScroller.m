//
//  WCBookmarksScroller.m
//  WCEdit
//
//  Created by William Towe on 8/12/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCBookmarksScroller.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>
#import <WCFoundation/WCFoundation.h>

@interface WCBookmarksScroller ()
@property (weak,nonatomic) RACDisposable *notificationDisposable;
@end

@implementation WCBookmarksScroller

+ (BOOL)isCompatibleWithOverlayScrollers {
    return (self == [WCBookmarksScroller class]);
}

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag {
    [super drawKnobSlotInRect:slotRect highlight:flag];
    
    NSTextView *textView = [self.delegate textViewForBookmarksScroller:self];
    CGFloat const scaleY = NSHeight(textView.frame) / NSHeight(self.frame);
    
    for (id<WCBookmark> bookmark in [self.bookmarksDataSource bookmarks]) {
        NSUInteger glyphIndex = [textView.layoutManager glyphIndexForCharacterAtIndex:[bookmark rangeValue].location];
        NSRect lineRect = [textView.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL withoutAdditionalLayout:YES];
        NSRect rect = NSMakeRect(NSMinX(slotRect), NSMinY(slotRect) + floor(NSMinY(lineRect) / scaleY), NSWidth(slotRect), 1.0);
        
        if (!NSIntersectsRect(rect, slotRect))
            continue;
        
        [[NSColor lightGrayColor] setFill];
        NSRectFill(rect);
    }
}

- (void)setBookmarksDataSource:(id<WCBookmarksDataSource>)bookmarksDataSource {
    [self.notificationDisposable dispose];
    
    _bookmarksDataSource = bookmarksDataSource;
    
    if (self.bookmarksDataSource) {
        @weakify(self);
        
        [self setNotificationDisposable:
         [[[[RACSignal merge:@[[[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidAddBookmark object:bookmarksDataSource],
                               [[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidRemoveBookmark object:bookmarksDataSource]]]
            takeUntil:[self rac_willDeallocSignal]]
           deliverOn:[RACScheduler mainThreadScheduler]]
          subscribeNext:^(id _) {
              @strongify(self);

              [self setNeedsDisplay:YES];
        }]];
    }
}

@end
