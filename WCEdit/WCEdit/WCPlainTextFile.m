//
//  WCPlainTextFile.m
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

#import "WCPlainTextFile.h"
#import "WCTextStorage.h"
#import <WCFoundation/WCFoundation.h>
#import "NSTextStorage+WCExtensions.h"
#import <BlocksKit/BlocksKit.h>
#import "WCBookmark.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>

NSString *const WCPlainTextFileExtendedAttributeSelectedRange = @"com.williamtowellc.wcedit.extended-attribute.selected-range";
NSString *const WCPlainTextFileExtendedAttributeBookmarks = @"com.williamtowellc.wcedit.extended-attribute.bookmarks";

@interface WCPlainTextFile ()
@property (readwrite,strong,nonatomic) WCTextStorage *textStorage;
@property (readwrite,strong,nonatomic) NSUndoManager *undoManager;
@property (assign,nonatomic) NSStringEncoding encoding;

- (BOOL)_writeExtendedAttributesToURL:(NSURL *)url error:(NSError **)error;
@end

@implementation WCPlainTextFile
#pragma mark *** Subclass Overrides ***
- (instancetype)initWithFileURL:(NSURL *)fileURL UTI:(NSString *)UTI error:(NSError *__autoreleasing *)error {
    if (!(self = [super initWithFileURL:fileURL UTI:UTI error:error]))
        return nil;
    
    [self setTextStorage:[[WCTextStorage alloc] init]];
    [self setEncoding:NSUTF8StringEncoding];
    
    [self setUndoManager:[[NSUndoManager alloc] init]];
    
    if (self.fileURL) {
        NSNumber *encoding = [WCExtendedAttributesManager objectForAttribute:WCExtendedAttributesManagerExtendedAttributeAppleTextEncoding atURL:self.fileURL error:NULL];
        
        if (encoding)
            [self setEncoding:encoding.unsignedIntegerValue];
        
        NSData *data = [NSData dataWithContentsOfURL:self.fileURL options:NSDataReadingMappedIfSafe error:NULL];
        NSString *string = [[NSString alloc] initWithData:data encoding:self.encoding];
        
        [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withString:string];
        
        [self.textStorage addBookmarksWithRanges:[[WCExtendedAttributesManager objectForAttribute:WCPlainTextFileExtendedAttributeBookmarks atURL:self.fileURL error:NULL] bk_map:^id(NSString *obj) {
            return [NSValue valueWithRange:NSRangeFromString(obj)];
        }]];
    }
    
    @weakify(self);
    
    [[[RACSignal merge:@[[[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidAddBookmark object:self.textStorage],
                         [[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidRemoveBookmark object:self.textStorage],
                         [[NSNotificationCenter defaultCenter] rac_addObserverForName:WCBookmarksDataSourceNotificationDidRemoveBookmarks object:self.textStorage]]]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(id _) {
         @strongify(self);
         
         if (self.fileURL)
             [self _writeExtendedAttributesToURL:self.fileURL error:NULL];
    }];
    
    return self;
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSData *data = [self.textStorage.string dataUsingEncoding:self.encoding];
    
    if (![data writeToURL:url options:NSDataWritingAtomic error:error])
        return NO;
    
    return [self _writeExtendedAttributesToURL:url error:error];
}
#pragma mark *** Private Methods ***
- (BOOL)_writeExtendedAttributesToURL:(NSURL *)url error:(NSError **)error; {
    if (![WCExtendedAttributesManager setObject:@(self.encoding) forAttribute:WCExtendedAttributesManagerExtendedAttributeAppleTextEncoding atURL:url error:NULL])
        return NO;
    
    NSTextView *textView = [self.textStorage WC_firstResponderTextView];
    
    if (![WCExtendedAttributesManager setString:NSStringFromRange(textView.selectedRange) forAttribute:WCPlainTextFileExtendedAttributeSelectedRange atURL:url error:NULL])
        return NO;
    
    if (![WCExtendedAttributesManager setObject:[self.textStorage.bookmarks bk_map:^id(id<WCBookmark> bookmark) {
        return NSStringFromRange([bookmark rangeValue]);
    }] forAttribute:WCPlainTextFileExtendedAttributeBookmarks atURL:url error:NULL])
        return NO;
    
    return YES;
}

@end
