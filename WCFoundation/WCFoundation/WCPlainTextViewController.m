//
//  WCPlainTextViewController.m
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

#import "WCPlainTextViewController.h"
#import <WCFoundation/WCFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>

static void *kWCPlainTextViewControllerObservingContext = &kWCPlainTextViewControllerObservingContext;

@interface WCPlainTextViewController ()
@property (readwrite,unsafe_unretained,nonatomic) IBOutlet WCPlainTextView *textView;

@property (weak,nonatomic) WCPlainTextFile *plainTextFile;
@end

@implementation WCPlainTextViewController

- (NSBundle *)nibBundle {
    return WCFoundationBundle();
}

- (void)loadView {
    [super loadView];
    
    [self.textView.layoutManager replaceTextStorage:self.plainTextFile.textStorage];
    
    [self.textView.enclosingScrollView setVerticalRulerView:[[WCRulerView alloc] initWithScrollView:self.textView.enclosingScrollView dataSource:nil]];
    [self.textView.enclosingScrollView setHasHorizontalRuler:NO];
    [self.textView.enclosingScrollView setHasVerticalRuler:YES];
    [self.textView.enclosingScrollView setRulersVisible:YES];
    
    [self.textView setTypingAttributes:@{NSFontAttributeName: [NSFont userFixedPitchFontOfSize:12.0]}];
    
    [self.textView setHighlightCurrentLineColor:[NSColor colorWithRed:1.0 green:1.0 blue:.901960784 alpha:1.0]];
    
    [self.textView setAutoPairCharacters:YES];
    [self.textView setAutoPairCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"'\"`([{"]];
    [self.textView setAutoPairLeftCharactersToRightCharacters:@{@('('): @(')'),
                                                                @('['): @(']'),
                                                                @('{'): @('}')}];
}

- (instancetype)initWithPlainTextFile:(WCPlainTextFile *)plainTextFile; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(plainTextFile);
    
    [self setPlainTextFile:plainTextFile];
    
    return self;
}

@end
