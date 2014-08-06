//
//  WCDocument.m
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

#import "WCDocument.h"
#import "WCDocumentWindowController.h"
#import <WCFoundation/WCFoundation.h>

@interface WCDocument ()
@property (weak,nonatomic) WCDocumentWindowController *documentWindowController;

@property (readwrite,strong,nonatomic) WCFile *file;
@end

@implementation WCDocument

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setHasUndoManager:NO];
    
    return self;
}
- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (!(self = [super initWithType:typeName error:outError]))
        return nil;
    
    [self setFile:[[[self fileClass] alloc] initWithFileURL:nil UTI:typeName error:NULL]];
    
    return self;
}

- (void)makeWindowControllers {
    WCDocumentWindowController *documentWindowController = [[WCDocumentWindowController alloc] initWithFile:self.file];
    
    [self addWindowController:documentWindowController];
    
    [self setDocumentWindowController:documentWindowController];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    [self setFile:[[[self fileClass] alloc] initWithFileURL:url UTI:typeName error:outError]];
    
    return (self.file) ? YES : NO;
}
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return [self.file writeToURL:url error:outError];
}

+ (BOOL)autosavesInPlace {
    return NO;
}
+ (BOOL)autosavesDrafts {
    return NO;
}

- (Class)fileClass; {
    return [WCFile class];
}

@end
