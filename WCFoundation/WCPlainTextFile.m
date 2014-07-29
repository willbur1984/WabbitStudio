//
//  WCPlainTextFile.m
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

#import "WCPlainTextFile.h"

@interface WCPlainTextFile ()
@property (readwrite,strong,nonatomic) NSTextStorage *textStorage;
@end

@implementation WCPlainTextFile

- (instancetype)initWithFileURL:(NSURL *)fileURL UTI:(NSString *)UTI {
    if (!(self = [super initWithFileURL:fileURL UTI:UTI]))
        return nil;
    
    NSFont *font = [NSFont userFixedPitchFontOfSize:12.0];
    
    if (self.fileURL) {
        NSData *data = [NSData dataWithContentsOfURL:self.fileURL options:NSDataReadingMappedIfSafe error:NULL];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [self setTextStorage:[[NSTextStorage alloc] initWithString:string attributes:@{NSFontAttributeName: font}]];
    }
    else {
        [self setTextStorage:[[NSTextStorage alloc] initWithString:@"" attributes:@{NSFontAttributeName: font}]];
    }
    
    return self;
}

@end
