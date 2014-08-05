//
//  WCTextStorage.m
//  WCEdit
//
//  Created by William Towe on 8/2/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCTextStorage.h"
#import <WCFoundation/WCFoundation.h>
#import "NSPointerArray+WCExtensions.h"
#import "WCLineNumbersRulerView.h"
#import "Bookmark.h"
#import "WCEditFunctions.h"
#import <BlocksKit/BlocksKit.h>

@interface WCTextStorage ()
@property (strong,nonatomic) NSMutableAttributedString *mutableAttributedString;
@property (copy,nonatomic) NSPointerArray *lineStartIndexes;
@property (strong,nonatomic) NSPersistentStoreCoordinator *bookmarksPersistentStoreCoordinator;
@property (strong,nonatomic) NSManagedObjectContext *bookmarksManagedObjectContext;

- (void)_recalculateLineStartIndexesFromLineNumber:(NSUInteger)lineNumber;
@end

@implementation WCTextStorage
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    WCLogObject(self.class);
}

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setMutableAttributedString:[[NSMutableAttributedString alloc] init]];
    
    [self setLineStartIndexes:[NSPointerArray pointerArrayWithOptions:NSPointerFunctionsIntegerPersonality|NSPointerFunctionsOpaqueMemory]];
    [self.lineStartIndexes addPointer:(void *)0];
    
    [self setBookmarksPersistentStoreCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:[WCEditBundle() URLForResource:@"Bookmarks" withExtension:@"momd"]]]];
    [self.bookmarksPersistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    
    [self setBookmarksManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    [self.bookmarksManagedObjectContext setPersistentStoreCoordinator:self.bookmarksPersistentStoreCoordinator];
    [self.bookmarksManagedObjectContext setUndoManager:nil];
    
    return self;
}
#pragma mark NSAttributedString
- (NSString *)string {
    return self.mutableAttributedString.string;
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [self.mutableAttributedString attributesAtIndex:location effectiveRange:range];
}
#pragma mark NSMutableAttributedString
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [self.mutableAttributedString replaceCharactersInRange:range withString:str];
    
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
}
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [self.mutableAttributedString setAttributes:attrs range:range];
    
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)fixFontAttributeInRange:(NSRange)range {
    [super fixFontAttributeInRange:range];
    
    [self addAttribute:NSFontAttributeName value:[NSFont userFixedPitchFontOfSize:12.0] range:range];
}
#pragma mark NSTextStorage
- (void)processEditing {
    BOOL editedCharacters = ((self.editedMask & NSTextStorageEditedCharacters) != 0);
    NSRange editedRange = self.editedRange;
    NSInteger changeInLength = self.changeInLength;
    
    [super processEditing];
    
    if (editedCharacters) {
        [self _recalculateLineStartIndexesFromLineNumber:[self lineNumberForRange:self.editedRange]];
        
        NSArray *bookmarks = [self sortedBookmarksInInclusiveRange:NSMakeRange(editedRange.location, self.length - editedRange.location)];
        
        if (bookmarks.count > 0) {
            for (Bookmark *bookmark in bookmarks)
                [bookmark setLineStartIndex:@(bookmark.lineStartIndexValue + changeInLength)];
            
            [self.bookmarksManagedObjectContext save:NULL];
        }
    }
}
#pragma mark WCLineNumbersDataSource
- (NSUInteger)numberOfLines {
    return self.lineStartIndexes.count;
}
- (NSUInteger)lineNumberForRange:(NSRange)range {
    return [self.lineStartIndexes WC_lineNumberForRange:range];
}
- (NSUInteger)lineStartIndexForLineNumber:(NSUInteger)lineNumber {
    return (NSUInteger)[self.lineStartIndexes pointerAtIndex:lineNumber];
}
#pragma mark WCBookmarksDataSource
- (NSArray *)bookmarks; {
    return [self.bookmarksManagedObjectContext WC_fetchEntityNamed:[Bookmark entityName] predicate:nil sortDescriptors:nil];
}
- (NSArray *)sortedBookmarks; {
    return [self.bookmarksManagedObjectContext WC_fetchEntityNamed:[Bookmark entityName] predicate:nil sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BookmarkAttributes.lineStartIndex ascending:YES]]];
}
- (NSArray *)sortedBookmarksInInclusiveRange:(NSRange)range; {
    range = [self.string lineRangeForRange:range];

    return [self.bookmarksManagedObjectContext WC_fetchEntityNamed:[Bookmark entityName] predicate:[NSPredicate predicateWithFormat:@"%K >= %@ AND %K <= %@",BookmarkAttributes.lineStartIndex,@(range.location),BookmarkAttributes.lineStartIndex,@(NSMaxRange(range))] sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BookmarkAttributes.lineStartIndex ascending:YES]]];
}
- (NSArray *)sortedBookmarksInExclusiveRange:(NSRange)range; {
    range = [self.string lineRangeForRange:range];
    
    return [self.bookmarksManagedObjectContext WC_fetchEntityNamed:[Bookmark entityName] predicate:[NSPredicate predicateWithFormat:@"%K > %@ AND %K < %@",BookmarkAttributes.lineStartIndex,@(range.location),BookmarkAttributes.lineStartIndex,@(NSMaxRange(range))] sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:BookmarkAttributes.lineStartIndex ascending:YES]]];
}

- (id<WCBookmark>)addBookmarkWithRange:(NSRange)range {
    Bookmark *retval = [NSEntityDescription insertNewObjectForEntityForName:[Bookmark entityName] inManagedObjectContext:self.bookmarksManagedObjectContext];
    NSUInteger lineNumber = [self lineNumberForRange:range];
    NSUInteger lineStartIndex = [self lineStartIndexForLineNumber:lineNumber];
    
    [retval setLineStartIndex:@(lineStartIndex)];
    [retval setRange:[NSValue valueWithRange:range]];
    
    [self.bookmarksManagedObjectContext save:NULL];
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:WCBookmarksDataSourceNotificationDidAddBookmark object:self] postingStyle:NSPostWhenIdle];
    
    return retval;
}
- (NSArray *)addBookmarksWithRanges:(NSArray *)ranges; {
    NSArray *retval = [ranges bk_map:^id(NSValue *range) {
        return [self addBookmarkWithRange:range.rangeValue];
    }];
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:WCBookmarksDataSourceNotificationDidAddBookmarks object:self] postingStyle:NSPostWhenIdle];
    
    return retval;
}

- (void)removeBookmark:(id<WCBookmark>)bookmark {
    NSParameterAssert(bookmark);
    
    Bookmark *object = [self.bookmarksManagedObjectContext WC_fetchEntityNamed:[Bookmark entityName] limit:1 predicate:[NSPredicate predicateWithFormat:@"%K == %@",BookmarkAttributes.lineStartIndex,@([bookmark lineStartIndexValue])] sortDescriptors:nil error:NULL].firstObject;
    
    [self.bookmarksManagedObjectContext deleteObject:object];
    [self.bookmarksManagedObjectContext save:NULL];
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:WCBookmarksDataSourceNotificationDidRemoveBookmark object:self] postingStyle:NSPostWhenIdle];
}
- (void)removeAllBookmarks {
    for (Bookmark *object in [self bookmarks])
        [self.bookmarksManagedObjectContext deleteObject:object];
    
    [self.bookmarksManagedObjectContext save:NULL];
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:WCBookmarksDataSourceNotificationDidRemoveBookmarks object:self] postingStyle:NSPostWhenIdle];
}
#pragma mark *** Private Methods ***
- (void)_recalculateLineStartIndexesFromLineNumber:(NSUInteger)lineNumber; {
    NSUInteger characterIndex = (NSUInteger)[self.lineStartIndexes pointerAtIndex:lineNumber];
    
    [self.lineStartIndexes setCount:lineNumber];
    
    do {
        
        [self.lineStartIndexes addPointer:(void *)characterIndex];
        
        characterIndex = NSMaxRange([self.string lineRangeForRange:NSMakeRange(characterIndex, 0)]);
        
    } while (characterIndex < self.length);
    
    NSUInteger contentsEnd, lineEnd;
    
    [self.string getLineStart:NULL end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange((NSUInteger)[self.lineStartIndexes pointerAtIndex:self.lineStartIndexes.count - 1], 0)];
    
    if (contentsEnd < self.length)
        [self.lineStartIndexes addPointer:(void *)characterIndex];
}

@end
