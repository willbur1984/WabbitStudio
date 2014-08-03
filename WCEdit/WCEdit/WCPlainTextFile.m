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

NSString *const WCPlainTextFileExtendedAttributeSelectedRange = @"com.williamtowellc.wcedit.extended-attribute.selected-range";
NSString *const WCPlainTextFileExtendedAttributeBookmarks = @"com.williamtowellc.wcedit.extended-attribute.bookmarks";

@interface WCPlainTextFile ()
@property (readwrite,strong,nonatomic) WCTextStorage *textStorage;
@property (assign,nonatomic) NSStringEncoding encoding;
@end

@implementation WCPlainTextFile

- (instancetype)initWithFileURL:(NSURL *)fileURL UTI:(NSString *)UTI error:(NSError *__autoreleasing *)error {
    if (!(self = [super initWithFileURL:fileURL UTI:UTI error:error]))
        return nil;
    
    [self setTextStorage:[[WCTextStorage alloc] init]];
    [self setEncoding:NSUTF8StringEncoding];
    
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
    
    return self;
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSData *data = [self.textStorage.string dataUsingEncoding:self.encoding];
    BOOL retval = [data writeToURL:url options:NSDataWritingAtomic error:error];
    
    if (retval) {
        [WCExtendedAttributesManager setObject:@(self.encoding) forAttribute:WCExtendedAttributesManagerExtendedAttributeAppleTextEncoding atURL:url error:NULL];
        
        NSTextView *textView = [self.textStorage WC_firstResponderTextView];
        
        [WCExtendedAttributesManager setString:NSStringFromRange(textView.selectedRange) forAttribute:WCPlainTextFileExtendedAttributeSelectedRange atURL:url error:NULL];
        
        [WCExtendedAttributesManager setObject:[self.textStorage.bookmarks bk_map:^id(id<WCBookmark> bookmark) {
            return NSStringFromRange([bookmark rangeValue]);
        }] forAttribute:WCPlainTextFileExtendedAttributeBookmarks atURL:url error:NULL];
    }
    
    return retval;
}

@end
