//
//  WCTextView.m
//  WCEdit
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
#import "NSTextView+WCExtensions.h"

@interface WCPlainTextView ()
@property (assign,nonatomic) unichar lastAutoPairRightCharacter;

- (void)_WCTextView_init;

- (void)_showFindIndicatorForMatchingPairCharactersImpl;
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
                if (self.wrapSelectedTextWithPairCharacters) {
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
                    [super insertText:insertString];
                    
                    [self setLastAutoPairRightCharacter:0];
                }
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
    [self setShowFindIndicatorForMatchingPairCharacters:YES];
    
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
     subscribeNext:^(NSNotification *value) {
         @strongify(self);
         
         if (self.highlightCurrentLine &&
             self.highlightCurrentLineColor) {
             
             [self setNeedsDisplayInRect:self.visibleRect avoidAdditionalLayout:YES];
         }
         
         if (self.autoPairLeftCharactersToRightCharacters &&
             self.showFindIndicatorForMatchingPairCharacters) {
             
             NSRange oldSelectedRange = [value.userInfo[@"NSOldSelectedCharacterRange"] rangeValue];
             
             if (oldSelectedRange.length == 0 &&
                 oldSelectedRange.location < self.selectedRange.location &&
                 self.selectedRange.location - oldSelectedRange.location == 1) {
                 
                 [self _showFindIndicatorForMatchingPairCharactersImpl];
             }
         }
    }];
}

- (void)_showFindIndicatorForMatchingPairCharactersImpl; {
    // return early if we dont have at least two characters or if we have text selected
    if (self.string.length <= 1 ||
        self.selectedRange.length > 0)
        return;
    
    unichar rightCharacter = [self.string characterAtIndex:self.selectedRange.location - 1];
    
    // return early if the character is not a valid right pair character
    if (![self.autoPairLeftCharactersToRightCharacters.allValues containsObject:@(rightCharacter)])
        return;
    
    NSRange visibleRange = [self WC_visibleRange];
    NSUInteger count = self.selectedRange.location - visibleRange.location;
    unichar parseCharacters[count];
    
    // grab characters from the first visible character to the insertion point
    [self.string getCharacters:parseCharacters range:NSMakeRange(visibleRange.location, count)];
    
    // grab the correct left char by comparing obj to the right character
    unichar leftCharacter = [[[self.autoPairLeftCharactersToRightCharacters keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        BOOL retval = ([obj unsignedShortValue] == rightCharacter);
        
        if (retval)
            *stop = YES;
        
        return retval;
    }] anyObject] unsignedShortValue];
    NSUInteger leftCount = 0;
    NSUInteger rightCount = 0;
    
    // loop backwards from the last char to the first
    for (NSInteger i=count-1; i>0; i--) {
        unichar character = parseCharacters[i];
        
        // increment left count
        if (character == leftCharacter) {
            leftCount++;
            
            // if left and right count are equal, we are balanced, show the find indicator and return
            if (leftCount == rightCount) {
                [self showFindIndicatorForRange:NSMakeRange(visibleRange.location + i, 1)];
                return;
            }
            // otherwise if left > right, we are not balanced, beep and return
            else if (leftCount > rightCount) {
                NSBeep();
                return;
            }
        }
        else if (character == rightCharacter) {
            rightCount++;
        }
    }
    
    // beep if we parsed to the last character and didnt find a match
    NSBeep();
}

@end
