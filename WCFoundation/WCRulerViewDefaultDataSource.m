//
//  WCRulerViewDefaultDataSource.m
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCRulerViewDefaultDataSource.h"
#import "NSPointerArray+WCExtensions.h"
#import "WCDebugging.h"

@interface WCRulerViewDefaultDataSource ()
@property (copy,nonatomic) NSPointerArray *lineStartIndexes;

@property (weak,nonatomic) WCRulerView *rulerView;
@property (weak,nonatomic) id textStorageDidProcessEditingNotificationToken;

- (void)_recalculateLineStartIndexes;
- (void)_recalculateLineStartIndexesFromLineNumber:(NSUInteger)lineNumber;
@end

@implementation WCRulerViewDefaultDataSource
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    WCLogObject(self.class);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.textStorageDidProcessEditingNotificationToken];
}
#pragma mark WCRulerViewDataSource
- (NSUInteger)numberOfLinesInRulerView:(WCRulerView *)rulerView {
    return self.lineStartIndexes.count;
}
- (NSUInteger)rulerView:(WCRulerView *)rulerView lineNumberForRange:(NSRange)range {
    return [self.lineStartIndexes WC_lineNumberForRange:range];
}
- (NSUInteger)rulerView:(WCRulerView *)rulerView lineStartIndexForLineNumber:(NSUInteger)lineNumber {
    return (NSUInteger)[self.lineStartIndexes pointerAtIndex:lineNumber];
}
#pragma mark *** Public Methods ***
- (instancetype)initWithRulerView:(WCRulerView *)rulerView {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(rulerView);
    
    [self setRulerView:rulerView];
    
    [self setLineStartIndexes:[NSPointerArray pointerArrayWithOptions:NSPointerFunctionsIntegerPersonality|NSPointerFunctionsOpaqueMemory]];
    [self.lineStartIndexes addPointer:(void *)0];
    
    [self _recalculateLineStartIndexes];
    
    __weak typeof(self) wself = self;
    
    [self setTextStorageDidProcessEditingNotificationToken:[[NSNotificationCenter defaultCenter] addObserverForName:NSTextStorageDidProcessEditingNotification object:rulerView.textView queue:nil usingBlock:^(NSNotification *note) {
        __strong typeof(wself) sself = wself;
        
        NSTextStorage *textStorage = note.object;
        
        if ((textStorage.editedMask & NSTextStorageEditedCharacters) == 0)
            return;
        
        [sself _recalculateLineStartIndexesFromLineNumber:[sself rulerView:sself.rulerView lineNumberForRange:textStorage.editedRange]];
    }]];
    
    return self;
}

#pragma mark *** Private Methods ***
- (void)_recalculateLineStartIndexes; {
    [self _recalculateLineStartIndexesFromLineNumber:0];
}
- (void)_recalculateLineStartIndexesFromLineNumber:(NSUInteger)lineNumber; {
    NSUInteger characterIndex = (NSUInteger)[self.lineStartIndexes pointerAtIndex:lineNumber];
    
    [self.lineStartIndexes setCount:lineNumber];
    
    do {
        
        [self.lineStartIndexes addPointer:(void *)characterIndex];
        
        characterIndex = NSMaxRange([self.rulerView.textView.textStorage.string lineRangeForRange:NSMakeRange(characterIndex, 0)]);
        
    } while (characterIndex < self.rulerView.textView.textStorage.length);
    
    NSUInteger contentsEnd, lineEnd;
    
    [self.rulerView.textView.textStorage.string getLineStart:NULL end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange((NSUInteger)[self.lineStartIndexes pointerAtIndex:self.lineStartIndexes.count - 1], 0)];
    
    if (contentsEnd < self.rulerView.textView.textStorage.length)
        [self.lineStartIndexes addPointer:(void *)characterIndex];
}

@end
