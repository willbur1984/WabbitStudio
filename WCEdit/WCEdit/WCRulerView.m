//
//  WCRulerView.m
//  WCEdit
//
//  Created by William Towe on 7/28/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCRulerView.h"
#import <WCFoundation/WCFoundation.h>
#import "WCRulerViewDefaultDataSource.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>

@interface WCRulerView ()
@property (readwrite,weak,nonatomic) id<WCRulerViewDataSource> dataSource;
@property (strong,nonatomic) WCRulerViewDefaultDataSource *defaultDataSource;
@end

@implementation WCRulerView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    WCLogObject(self.class);
}

- (instancetype)initWithScrollView:(NSScrollView *)scrollView dataSource:(id<WCRulerViewDataSource>)dataSource; {
    if (!(self = [super initWithScrollView:scrollView orientation:NSVerticalRuler]))
        return nil;
    
    NSParameterAssert([scrollView.documentView isKindOfClass:[NSTextView class]]);
    
    [self setClientView:scrollView.documentView];
    
    [self setDataSource:dataSource];
    
    if (!dataSource) {
        [self setDefaultDataSource:[[WCRulerViewDefaultDataSource alloc] initWithRulerView:self]];
        [self setDataSource:self.defaultDataSource];
    }
    
    @weakify(self);
    
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:NSTextStorageDidProcessEditingNotification object:self.textView.textStorage]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(NSNotification *value) {
         @strongify(self);
         
         NSTextStorage *textStorage = value.object;
         
         if ((textStorage.editedMask & NSTextStorageEditedCharacters) == 0)
             return;
         
         [self setNeedsDisplayInRect:self.visibleRect];
    }];
    
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:NSTextViewDidChangeSelectionNotification object:self.textView]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(id _) {
         @strongify(self);
         
         [self setNeedsDisplayInRect:self.visibleRect];
    }];
    
    return self;
}

- (void)viewWillDraw {
    [super viewWillDraw];
    
    CGFloat newThickness = self.requiredThickness;
	
	if (fabs(self.ruleThickness - newThickness) > 1)
		[self setRuleThickness:newThickness];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
    [self drawBackgroundInRect:rect];
    [self drawLineNumbersInRect:rect];
}

- (BOOL)isOpaque {
    return YES;
}

static CGFloat const kStringMarginLeftRight = 4.0;
static CGFloat const kDefaultThickness = 30.0;
static NSString *const kDefaultDigit = @"8";

- (CGFloat)requiredThickness {
    NSMutableString *sampleString = [[NSMutableString alloc] init];
    NSUInteger digits = (NSUInteger)log10([self.dataSource numberOfLinesInRulerView:self]) + 1;
	
    for (NSUInteger i = 0; i < digits; i++)
        [sampleString appendString:kDefaultDigit];
    
    NSSize stringSize = [sampleString sizeWithAttributes:@{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]] }];
	
	return ceil(MAX(kDefaultThickness, stringSize.width + (kStringMarginLeftRight * 2)));
}
#pragma mark *** Public Methods ***
- (NSUInteger)lineNumberForPoint:(NSPoint)point; {
    NSRange glyphRange = [self.textView.layoutManager glyphRangeForBoundingRect:self.textView.visibleRect inTextContainer:self.textView.textContainer];
    NSRange charRange = [self.textView.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    NSUInteger lineNumber, lineStartIndex;
    
    charRange.length++;
    
    for (lineNumber = [self.dataSource rulerView:self lineNumberForRange:charRange]; lineNumber < [self.dataSource  numberOfLinesInRulerView:self]; lineNumber++) {
        lineStartIndex = [self.dataSource rulerView:self lineStartIndexForLineNumber:lineNumber];
        
        if (NSLocationInRange(lineStartIndex, charRange)) {
            NSUInteger numberOfLineRects;
            NSRectArray lineRects = [self.textView.layoutManager rectArrayForCharacterRange:[self.textView.string lineRangeForRange:NSMakeRange(lineStartIndex, 0)] withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textView.textContainer rectCount:&numberOfLineRects];
            
            if (numberOfLineRects) {
                NSRect lineRect = lineRects[0];
                
                if (numberOfLineRects > 1) {
                    NSUInteger rectIndex;
                    
                    for (rectIndex=1; rectIndex<numberOfLineRects; rectIndex++)
                        lineRect = NSUnionRect(lineRect, lineRects[rectIndex]);
                }
                
                NSRect hitRect = NSMakeRect(NSMinX(self.bounds), [self convertPoint:lineRect.origin fromView:self.clientView].y, NSWidth(self.frame), NSHeight(lineRect));
                
                if (point.y >= NSMinY(hitRect) && point.y < NSMaxY(hitRect))
                    return lineNumber;
            }
        }
        
        if (lineStartIndex > NSMaxRange(charRange))
			break;
    }
    return NSNotFound;
}

- (void)drawBackgroundInRect:(NSRect)rect; {
    [[NSColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0] setFill];
    NSRectFill(rect);
    
    [[NSColor lightGrayColor] setFill];
    NSRectFill(NSMakeRect(NSMaxX(rect) - 1, 0, 1, NSHeight(self.frame)));
}
- (void)drawLineNumbersInRect:(NSRect)rect; {
    NSRange glyphRange = [self.textView.layoutManager glyphRangeForBoundingRect:self.textView.visibleRect inTextContainer:self.textView.textContainer];
    NSRange charRange = [self.textView.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    NSUInteger lineNumber, lineStartIndex;
    NSIndexSet *selectedLineNumbers = [self selectedLineNumbers];
    CGFloat lastLineRectY = -1;
    
    for (lineNumber = [self.dataSource rulerView:self lineNumberForRange:charRange], charRange.length++; lineNumber < [self.dataSource numberOfLinesInRulerView:self]; lineNumber++) {
        lineStartIndex = [self.dataSource rulerView:self lineStartIndexForLineNumber:lineNumber];
        
        if (NSLocationInRange(lineStartIndex, charRange)) {
            NSUInteger numberOfLineRects;
            NSRectArray lineRects = [self.textView.layoutManager rectArrayForCharacterRange:NSMakeRange(lineStartIndex, 0) withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textView.textContainer rectCount:&numberOfLineRects];
            
            if (numberOfLineRects) {
                NSRect lineRect = lineRects[0];
                
                if (NSMinY(lineRect) != lastLineRectY) {
                    NSString *lineNumberString = [NSString stringWithFormat:@"%@",@(lineNumber + 1)];
                    NSDictionary *attributes = ([selectedLineNumbers containsIndex:lineNumber]) ? self.selectedStringAttributes : self.stringAttributes;
                    NSSize stringSize = [lineNumberString sizeWithAttributes:attributes];
                    NSRect drawRect = NSMakeRect(NSMinX(rect), [self convertPoint:lineRect.origin fromView:self.clientView].y + (NSHeight(lineRect) * 0.5) - (stringSize.height * 0.5), NSWidth(rect) - kStringMarginLeftRight, stringSize.height);
                    
                    [lineNumberString drawInRect:drawRect withAttributes:attributes];
                }
                
                lastLineRectY = NSMinY(lineRect);
            }
        }
        
        if (lineStartIndex > NSMaxRange(charRange))
			break;
    }
}
#pragma mark Properties
- (void)setDataSource:(id<WCRulerViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    if (![self.dataSource isEqual:self.defaultDataSource])
        [self setDefaultDataSource:nil];
}

- (NSTextView *)textView {
    return (NSTextView *)self.clientView;
}

- (NSDictionary *)stringAttributes {
    return @{NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]], NSForegroundColorAttributeName : [NSColor lightGrayColor], NSParagraphStyleAttributeName : [NSParagraphStyle WC_rightAlignedParagraphStyle]};
}
- (NSDictionary *)selectedStringAttributes {
    return @{NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]], NSForegroundColorAttributeName : [NSColor blackColor], NSParagraphStyleAttributeName : [NSParagraphStyle WC_rightAlignedParagraphStyle]};
}

- (NSIndexSet *)selectedLineNumbers; {
    NSMutableIndexSet *retval = [NSMutableIndexSet indexSet];
    
    NSRange selectedLineRange = [self.textView.string lineRangeForRange:self.textView.selectedRange];
    NSUInteger startLineNumber = [self.dataSource rulerView:self lineNumberForRange:NSMakeRange(selectedLineRange.location, 0)];
    
    if (self.textView.selectedRange.length == 0)
        [retval addIndex:startLineNumber];
    
    return retval;
}

@end
