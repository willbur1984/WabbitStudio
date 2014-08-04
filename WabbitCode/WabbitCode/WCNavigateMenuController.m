//
//  WCNavigateMenuController.m
//  WabbitCode
//
//  Created by William Towe on 8/3/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCNavigateMenuController.h"
#import <WCFoundation/WCFoundation.h>
#import <WCEdit/WCEdit.h>
#import "WCDocumentController.h"
#import "WCPlainTextDocument.h"

@interface WCNavigateMenuController () <NSMenuDelegate>
@property (weak,nonatomic) IBOutlet NSMenu *goToBookmarkMenu;

- (NSMenuItem *)_removeAllBookmarksMenuItem;

- (IBAction)_toggleBookmarkAction:(id)sender;
- (IBAction)_nextBookmarkAction:(id)sender;
- (IBAction)_previousBookmarkAction:(id)sender;
- (IBAction)_goToBookmarkAction:(id)sender;
- (IBAction)_removeAllBookmarksAction:(id)sender;
@end

@implementation WCNavigateMenuController
#pragma mark *** Subclass Overrides ***
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.goToBookmarkMenu setDelegate:self];
}
#pragma mark NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.action == @selector(_toggleBookmarkAction:)) {
        WCPlainTextDocument *document = [[WCDocumentController sharedDocumentController] currentPlainTextDocument];
        
        if (!document)
            return NO;
        
        WCTextStorage *textStorage = document.plainTextFile.textStorage;
        NSTextView *textView = [textStorage WC_firstResponderTextView];
        
        if (!textView)
            return NO;
        
        id<WCBookmark> bookmark = [textStorage sortedBookmarksInInclusiveRange:textView.selectedRange].firstObject;
        
        if (bookmark) {
            [menuItem setTitle:NSLocalizedString(@"Remove Bookmark", @"remove bookmark menu item title")];
        }
        else {
            [menuItem setTitle:NSLocalizedString(@"Add Bookmark", @"add bookmark menu item title")];
        }
    }
    else if (menuItem.action == @selector(_nextBookmarkAction:) ||
             menuItem.action == @selector(_previousBookmarkAction:) ||
             menuItem.action == @selector(_removeAllBookmarksAction:)) {
        
        WCPlainTextDocument *document = [[WCDocumentController sharedDocumentController] currentPlainTextDocument];
        
        if (!document)
            return NO;
        
        WCTextStorage *textStorage = document.plainTextFile.textStorage;
        NSTextView *textView = [textStorage WC_firstResponderTextView];
        
        if (!textView)
            return NO;
        
        NSArray *bookmarks = [textStorage bookmarks];
        
        return (bookmarks.count > 0);
    }
    return YES;
}
#pragma mark NSMenuDelegate
- (BOOL)menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(__autoreleasing id *)target action:(SEL *)action {
    return NO;
}
- (void)menuNeedsUpdate:(NSMenu *)menu {
    [menu removeAllItems];
    
    if (menu == self.goToBookmarkMenu) {
        WCPlainTextDocument *document = [[WCDocumentController sharedDocumentController] currentPlainTextDocument];
        
        if (document) {
            WCTextStorage *textStorage = document.plainTextFile.textStorage;
            NSArray *sortedBookmarks = [textStorage sortedBookmarks];
            
            if (sortedBookmarks.count > 0) {
                [sortedBookmarks enumerateObjectsUsingBlock:^(id<WCBookmark> bookmark, NSUInteger bookmarkIndex, BOOL *stop) {
                    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", @"bookmark menu item title format"),@([textStorage lineNumberForRange:[bookmark rangeValue]] + 1),[textStorage.string substringWithRange:[textStorage.string lineRangeForRange:[bookmark rangeValue]]]];
                    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(_goToBookmarkAction:) keyEquivalent:@""];
                    
                    [menuItem setTarget:self];
                    [menuItem setTag:bookmarkIndex];
                    
                    [menu addItem:menuItem];
                }];
                
                [menu addItem:[NSMenuItem separatorItem]];
            }
        }
        
        [menu addItem:[self _removeAllBookmarksMenuItem]];
    }
}
#pragma mark *** Private Methods ***
- (NSMenuItem *)_removeAllBookmarksMenuItem; {
    NSMenuItem *retval = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Remove All Bookmarks", @"remove all bookmarks menu item title") action:@selector(_removeAllBookmarksAction:) keyEquivalent:@""];
    
    [retval setTarget:self];
    
    return retval;
}
#pragma mark Actions
- (IBAction)_toggleBookmarkAction:(id)sender; {
    WCPlainTextDocument *document = [[WCDocumentController sharedDocumentController] currentPlainTextDocument];
    WCTextStorage *textStorage = document.plainTextFile.textStorage;
    NSTextView *textView = [textStorage WC_firstResponderTextView];
    id<WCBookmark> bookmark = [textStorage sortedBookmarksInInclusiveRange:textView.selectedRange].firstObject;
    
    if (bookmark) {
        [textStorage removeBookmark:bookmark];
    }
    else {
        [textStorage addBookmarkWithRange:textView.selectedRange];
    }
}
- (IBAction)_nextBookmarkAction:(id)sender; {
    WCPlainTextDocument *document = [[WCDocumentController sharedDocumentController] currentPlainTextDocument];
    WCTextStorage *textStorage = document.plainTextFile.textStorage;
    NSTextView *textView = [textStorage WC_firstResponderTextView];
    NSRange lineRange = [textStorage.string lineRangeForRange:textView.selectedRange];
    NSArray *bookmarks = [textStorage sortedBookmarksInInclusiveRange:NSMakeRange(NSMaxRange(lineRange), textStorage.length - NSMaxRange(lineRange))];
    id<WCBookmark> bookmark;
    
    if (bookmarks.count > 0)
        bookmark = bookmarks.firstObject;
    else
        bookmark = [textStorage sortedBookmarks].firstObject;
    
    [textView setSelectedRange:[bookmark rangeValue]];
    [textView scrollRangeToVisible:textView.selectedRange];
}
- (IBAction)_previousBookmarkAction:(id)sender; {
    WCPlainTextDocument *document = [[WCDocumentController sharedDocumentController] currentPlainTextDocument];
    WCTextStorage *textStorage = document.plainTextFile.textStorage;
    NSTextView *textView = [textStorage WC_firstResponderTextView];
    NSRange lineRange = [textStorage.string lineRangeForRange:textView.selectedRange];
    NSArray *bookmarks = [textStorage sortedBookmarksInExclusiveRange:NSMakeRange(0, lineRange.location)];
    id<WCBookmark> bookmark;
    
    if (bookmarks.count > 0)
        bookmark = bookmarks.lastObject;
    else
        bookmark = [textStorage sortedBookmarks].lastObject;
    
    [textView setSelectedRange:[bookmark rangeValue]];
    [textView scrollRangeToVisible:textView.selectedRange];
}
- (IBAction)_goToBookmarkAction:(NSMenuItem *)sender; {
    WCPlainTextDocument *document = [[WCDocumentController sharedDocumentController] currentPlainTextDocument];
    WCTextStorage *textStorage = document.plainTextFile.textStorage;
    id<WCBookmark> bookmark = [textStorage sortedBookmarks][sender.tag];
    NSTextView *textView = [textStorage WC_firstResponderTextView];
    
    [textView setSelectedRange:[bookmark rangeValue]];
    [textView scrollRangeToVisible:textView.selectedRange];
}
- (IBAction)_removeAllBookmarksAction:(id)sender; {
    WCPlainTextDocument *document = [[WCDocumentController sharedDocumentController] currentPlainTextDocument];
    WCTextStorage *textStorage = document.plainTextFile.textStorage;
    
    [textStorage removeAllBookmarks];
}

@end
