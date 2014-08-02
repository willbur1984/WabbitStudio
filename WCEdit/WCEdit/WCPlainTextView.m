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

#import "WCPlainTextView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>
#import <WCFoundation/WCFoundation.h>

@interface WCPlainTextView ()
@property (assign,nonatomic) unichar lastAutoPairRightCharacter;

- (void)_WCTextView_init;
@end

@implementation WCPlainTextView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    WCLogObject(self.class);
}

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

#pragma mark NSResponder
- (void)insertNewline:(id)sender {
    [super insertNewline:sender];
    
    if (self.automaticallyIndent) {
        // init the scanner with the string from the previous line
        NSScanner *scanner = [[NSScanner alloc] initWithString:[self.string substringWithRange:[self.string lineRangeForRange:NSMakeRange(self.selectedRange.location - 1, 0)]]];
        
        // normally NSScanner skips whitespace, we don't want that
        [scanner setCharactersToBeSkipped:nil];
        
        // scan all whitespace from the previous line and insert it
        NSString *whitespace;
        if ([scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&whitespace] &&
            whitespace.length > 0) {
            
            [self insertText:whitespace];
        }
    }
}
#pragma mark NSTextView
- (void)insertText:(id)insertString {
    // if we should auto pair characters, and the auto pair character set is non-nil, and the insertString is a single character, proceed
    if (self.autoPairCharacters &&
        self.autoPairCharacterSet &&
        [insertString length] == 1) {
        
        unichar leftCharacter = [(NSString *)insertString characterAtIndex:0];
        
        // if the character belongs to our auto pair character set
        if ([self.autoPairCharacterSet characterIsMember:leftCharacter]) {
            unichar rightCharacter = leftCharacter;
            
            // is there a specific right character for the left character? (e.g. [ and ])
            if (self.autoPairLeftCharactersToRightCharacters[@(leftCharacter)])
                rightCharacter = [self.autoPairLeftCharactersToRightCharacters[@(leftCharacter)] unsignedShortValue];
            
            // if there is text selected, wrap it in the paired characters and select the original selection plus the pair characters
            if (self.selectedRange.length > 0) {
                [self.undoManager WC_undoGroupWithBlock:^{
                    NSString *replacementString = [NSString stringWithFormat:@"%C%@%C",leftCharacter,[self.string substringWithRange:self.selectedRange],rightCharacter];
                    NSRange replacementSelectedRange = NSMakeRange(self.selectedRange.location, replacementString.length);
                    
                    if ([self shouldChangeTextInRange:self.selectedRange replacementString:replacementString]) {
                        [self replaceCharactersInRange:self.selectedRange withString:replacementString];
                        [self setSelectedRange:replacementSelectedRange];
                        
                        [self setLastAutoPairRightCharacter:rightCharacter];
                    }
                }];
            }
            else {
                // if the last right auto pair character is the same as the character immediately to the right of the insertion point, move the insertion point to the right of the right auto pair character
                if (leftCharacter == self.lastAutoPairRightCharacter &&
                    self.selectedRange.location < self.string.length &&
                    [self.string characterAtIndex:self.selectedRange.location] == self.lastAutoPairRightCharacter) {
                    [self moveRight:nil];
                    
                    [self setLastAutoPairRightCharacter:0];
                }
                // otherwise, insert the pair characters and move the insertion point between them
                else {
                    [self.undoManager WC_undoGroupWithBlock:^{
                        NSString *replacementString = [NSString stringWithFormat:@"%C%C",leftCharacter,rightCharacter];
                        NSRange replacementSelectedRange = NSMakeRange(self.selectedRange.location + 1, 0);
                        
                        if ([self shouldChangeTextInRange:self.selectedRange replacementString:replacementString]) {
                            [self replaceCharactersInRange:self.selectedRange withString:replacementString];
                            [self setSelectedRange:replacementSelectedRange];
                            
                            [self setLastAutoPairRightCharacter:rightCharacter];
                        }
                    }];
                }
            }
        }
        else {
            // if the last right auto pair character is the same as the character immediately to the right of the insertion point, move the insertion point to the right of the right auto pair character
            if (self.selectedRange.location < self.string.length &&
                [self.string characterAtIndex:self.selectedRange.location] == self.lastAutoPairRightCharacter) {
                [self moveRight:nil];
            }
            else {
                [super insertText:insertString];
            }
            
            [self setLastAutoPairRightCharacter:0];
        }
    }
    else {
        [super insertText:insertString];
        
        [self setLastAutoPairRightCharacter:0];
    }
}

- (void)drawViewBackgroundInRect:(NSRect)rect {
    [super drawViewBackgroundInRect:rect];
    
    // if we should highlight the current line, and we have a highlight current line color, and nothing is selected, proceed
    if (self.highlightCurrentLine &&
        self.highlightCurrentLineColor &&
        self.selectedRange.length == 0) {
        
        // get the entire line range for the selected range
        NSRange lineRange = [self.textStorage.string lineRangeForRange:self.selectedRange];
        // convert the line range to a glyph range
        NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:lineRange actualCharacterRange:NULL];
        // get the bounding rect for the glyph range, more direct than using rectArrayForCharacterRange:withinSelectedCharacterRange:inTextContainer:rectCount:
        NSRect lineRect = [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
        
        // the original x position will respect the textContainerInsert
        lineRect.origin.x = NSMinX(self.bounds);
        // change the width to be our full width
        lineRect.size.width = NSWidth(self.bounds);
        
        [self.highlightCurrentLineColor setFill];
        NSRectFill(lineRect);
    }
}
#pragma mark *** Private Methods ***
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
