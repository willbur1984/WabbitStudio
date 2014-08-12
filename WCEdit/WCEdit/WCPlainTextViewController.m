//
//  WCPlainTextViewController.m
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

#import "WCPlainTextViewController.h"
#import <WCFoundation/WCFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>
#import "WCPlainTextView.h"
#import "WCFindBarScrollView.h"
#import "WCTextFinder.h"
#import "WCEditFunctions.h"
#import "WCPlainTextFile.h"
#import "WCBookmarksRulerView.h"
#import "WCTextStorage.h"
#import "WCBookmarksScroller.h"

@interface WCPlainTextViewController () <WCBookmarksScrollerDelegate,NSTextViewDelegate>
@property (weak,nonatomic) IBOutlet WCFindBarScrollView *scrollView;
@property (readwrite,unsafe_unretained,nonatomic) IBOutlet WCPlainTextView *textView;

@property (weak,nonatomic) WCPlainTextFile *plainTextFile;

@property (strong,nonatomic) WCTextFinder *textFinder;

- (void)_loadExtendedAttributes;
@end

@implementation WCPlainTextViewController

- (NSBundle *)nibBundle {
    return WCEditBundle();
}

- (void)loadView {
    [super loadView];
    
    [self.textView.layoutManager replaceTextStorage:self.plainTextFile.textStorage];
    
    WCBookmarksRulerView *verticalRulerView = [[WCBookmarksRulerView alloc] initWithScrollView:self.textView.enclosingScrollView lineNumbersDataSource:self.plainTextFile.textStorage];
    
    [verticalRulerView setBookmarksDataSource:self.plainTextFile.textStorage];
    
    [self.textView.enclosingScrollView setVerticalRulerView:verticalRulerView];
    [self.textView.enclosingScrollView setHasHorizontalRuler:NO];
    [self.textView.enclosingScrollView setHasVerticalRuler:YES];
    [self.textView.enclosingScrollView setRulersVisible:YES];
    
    [self.textView setDelegate:self];
    
    WCBookmarksScroller *verticalScroller = [[WCBookmarksScroller alloc] initWithFrame:NSZeroRect];
    
    [verticalScroller setBookmarksDataSource:self.plainTextFile.textStorage];
    [verticalScroller setDelegate:self];
    
    [self.scrollView setVerticalScroller:verticalScroller];
    
    [self setTextFinder:[[WCTextFinder alloc] init]];
    [self.textFinder setClient:self.textView];
    [self.textFinder setViewContainer:self.scrollView];
    
    [self.textView setTextFinder:self.textFinder];
    
    [self _loadExtendedAttributes];
    
    @weakify(self);
    
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:NSTextStorageDidProcessEditingNotification object:self.plainTextFile.textStorage]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(NSNotification *value) {
         @strongify(self);
         
         NSTextStorage *textStorage = value.object;
         
         if ((textStorage.editedMask & NSTextStorageEditedCharacters) == 0)
             return;
         
         [self.textFinder noteClientStringDidChange];
    }];
}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)view {
    return self.plainTextFile.undoManager;
}

- (NSTextView *)textViewForBookmarksScroller:(WCBookmarksScroller *)bookmarksScroller {
    return self.textView;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.action == @selector(performTextFinderAction:))
        return [self.textFinder validateAction:menuItem.tag];
    return [super validateMenuItem:menuItem];
}
- (void)performTextFinderAction:(NSMenuItem *)sender {
    [self.textFinder performAction:sender.tag];
}

- (instancetype)initWithPlainTextFile:(WCPlainTextFile *)plainTextFile; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(plainTextFile);
    
    [self setPlainTextFile:plainTextFile];
    
    return self;
}

- (void)_loadExtendedAttributes; {
    NSString *selectedRangeString = [WCExtendedAttributesManager stringForAttribute:WCPlainTextFileExtendedAttributeSelectedRange atURL:self.plainTextFile.fileURL error:NULL];
    
    if (selectedRangeString) {
        NSRange selectedRange = NSRangeFromString(selectedRangeString);
        
        if (NSMaxRange(selectedRange) < self.textView.string.length) {
            [self.textView setSelectedRange:selectedRange];
            [self.textView scrollRangeToVisible:selectedRange];
        }
    }
}

@end
