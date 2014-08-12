//
//  WCFindBarScrollView.m
//  WCEdit
//
//  Created by William Towe on 8/9/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCFindBarScrollView.h"
#import <WCFoundation/WCFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>

@interface WCFindBarScrollView ()
- (void)_WCFindBarScrollView_init;
@end

@implementation WCFindBarScrollView

- (id)initWithFrame:(NSRect)frameRect {
    if (!(self = [super initWithFrame:frameRect]))
        return nil;
    
    [self _WCFindBarScrollView_init];
    
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self _WCFindBarScrollView_init];
    
    return self;
}

- (void)tile {
    [super tile];
    
    if (self.textFinderView) {
        if (self.isTextFinderViewVisible) {
            [self.textFinderView setFrame:NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.bounds), self.textFinderView.intrinsicContentSize.height)];
            [self.verticalRulerView setFrame:NSMakeRect(NSMinX(self.verticalRulerView.frame), NSMaxY(self.textFinderView.frame), NSWidth(self.verticalRulerView.frame), NSHeight(self.verticalRulerView.frame) - self.textFinderView.intrinsicContentSize.height)];
            [self.verticalScroller setFrame:NSMakeRect(NSMinX(self.verticalScroller.frame), NSMaxY(self.textFinderView.frame), NSWidth(self.verticalScroller.frame), NSHeight(self.verticalScroller.frame) - self.textFinderView.intrinsicContentSize.height)];
            [self.contentView setFrame:NSMakeRect(NSMinX(self.contentView.frame), NSMaxY(self.textFinderView.frame), NSWidth(self.contentView.frame), NSHeight(self.contentView.frame) - self.textFinderView.intrinsicContentSize.height)];
        }
        else {
            [self.textFinderView setFrame:NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds) - self.textFinderView.intrinsicContentSize.height, NSWidth(self.bounds), self.textFinderView.intrinsicContentSize.height)];
        }
    }
}

@synthesize textFinderView=_textFinderView;
- (void)setTextFinderView:(NSView *)textFinderView {
    if (_textFinderView == textFinderView)
        return;
    
    [self.textFinderView removeFromSuperview];
    
    _textFinderView = textFinderView;
    
    if (self.textFinderView)
        [self addSubview:self.textFinderView positioned:NSWindowAbove relativeTo:nil];
}
@synthesize textFinderViewVisible=_textFinderViewVisible;

- (void)textFinderViewDidChangeHeight {
    [self tile];
}

- (void)_WCFindBarScrollView_init; {
    @weakify(self);
    
    [[[RACObserve(self, textFinderViewVisible)
       distinctUntilChanged]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSNumber *value) {
         @strongify(self);
         
         [self tile];
    }];
}

@end
