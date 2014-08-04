//
//  WCBookmarkViewModel.m
//  WCEdit
//
//  Created by William Towe on 8/3/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCBookmarkViewModel.h"
#import "WCEditFunctions.h"

@interface WCBookmarkViewModel ()
@property (readwrite,strong,nonatomic) id<WCBookmark> bookmark;
@end

@implementation WCBookmarkViewModel

- (instancetype)initWithBookmark:(id<WCBookmark>)bookmark; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(bookmark);
    
    [self setBookmark:bookmark];
    
    return self;
}

- (void)drawInRect:(NSRect)rect; {
    NSImage *image = [WCEditBundle() imageForResource:@"Bookmark"];
    CGImageRef imageRef = [image CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil];
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), CGImageGetBitsPerComponent(imageRef), CGImageGetBitsPerPixel(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetDataProvider(imageRef), NULL, false);
    
    [NSGraphicsContext saveGraphicsState];
    
    CGContextClipToMask([[NSGraphicsContext currentContext] graphicsPort], rect, imageMask);
    CGImageRelease(imageMask);
    
    [[NSColor lightGrayColor] setFill];
    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
