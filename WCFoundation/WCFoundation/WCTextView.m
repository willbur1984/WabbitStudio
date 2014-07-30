//
//  WCTextView.m
//  WCFoundation
//
//  Created by William Towe on 7/29/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCTextView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>
#import "WCConstants.h"
#import "WCDebugging.h"

@interface WCTextView ()

- (void)_WCTextView_init;
@end

@implementation WCTextView

- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container {
    if (!(self = [super initWithFrame:frameRect textContainer:container]))
        return nil;
    
    [self _WCTextView_init];
    
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self _WCTextView_init];
    
    return self;
}

- (void)drawViewBackgroundInRect:(NSRect)rect {
    [super drawViewBackgroundInRect:rect];
    
    if (self.highlightCurrentLine &&
        self.highlightCurrentLineColor) {
        
        if (self.selectedRange.length == 0) {
            NSRange lineRange = [self.textStorage.string lineRangeForRange:self.selectedRange];
            NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:lineRange actualCharacterRange:NULL];
            NSRect lineRect = [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
            
            lineRect.origin.x = NSMinX(self.bounds);
            lineRect.size.width = NSWidth(self.bounds);
            
            [self.highlightCurrentLineColor setFill];
            NSRectFill(lineRect);
        }
    }
}

- (void)_WCTextView_init; {
    @unsafeify(self);
    
    [[[RACSignal merge:@[[RACObserve(self, highlightCurrentLine) distinctUntilChanged],
                         [RACObserve(self, highlightCurrentLineColor) distinctUntilChanged]]]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
         @strongify(self);
         
         [self setNeedsDisplayInRect:self.visibleRect avoidAdditionalLayout:YES];
    }];
    
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:NSTextViewDidChangeSelectionNotification object:self]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(id _) {
         @strongify(self);
         
         [self setNeedsDisplayInRect:self.visibleRect avoidAdditionalLayout:YES];
    }];
}

@end
