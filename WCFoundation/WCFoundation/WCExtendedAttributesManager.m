//
//  WCExtendedAttributesManager.m
//  WCFoundation
//
//  Created by William Towe on 8/2/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCExtendedAttributesManager.h"
#import "WCFoundationFunctions.h"
#import <sys/xattr.h>
#import <sys/errno.h>

@interface WCExtendedAttributesManager ()
+ (NSError *)_localizedErrorForErrnoCode:(int)errnoCode;
@end

@implementation WCExtendedAttributesManager

+ (NSArray *)attributesAtURL:(NSURL *)url error:(NSError **)error; {
    NSParameterAssert(url);
    
    size_t length = listxattr(url.path.fileSystemRepresentation, NULL, ULONG_MAX, 0);
    
    if (length == ULONG_MAX ||
        length == -1) {
        
        if (error)
            *error = [self _localizedErrorForErrnoCode:errno];
        
        return nil;
    }
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSMutableData *data = [[NSMutableData alloc] initWithLength:length];
    
    listxattr(url.path.fileSystemRepresentation, data.mutableBytes, data.length, 0);
    
    for (size_t i=0, j=0; i<length; i++) {
        if (((unsigned char *)data.bytes)[i] == 0) {
            NSString *attribute = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(j, i - j)] encoding:NSUTF8StringEncoding];
            
            [retval addObject:attribute];
            
            j = i;
        }
    }
    
    return [retval copy];
}

+ (BOOL)removeAttribute:(NSString *)attribute atURL:(NSURL *)url error:(NSError **)error; {
    NSParameterAssert(attribute);
    NSParameterAssert(url);
    
    int result = removexattr(url.path.fileSystemRepresentation, attribute.UTF8String, 0);
    
    if (result == -1) {
        if (error)
            *error = [self _localizedErrorForErrnoCode:errno];
        
        return NO;
    }
    
    return YES;
}

+ (NSString *)stringForAttribute:(NSString *)attribute atURL:(NSURL *)url error:(NSError **)error; {
    NSData *data = [self dataForAttribute:attribute atURL:url error:error];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
+ (BOOL)setString:(NSString *)string forAttribute:(NSString *)attribute atURL:(NSURL *)url error:(NSError **)error; {
    return [self setData:[string dataUsingEncoding:NSUTF8StringEncoding] forAttribute:attribute atURL:url error:error];
}

+ (id)objectForAttribute:(NSString *)attribute atURL:(NSURL *)url error:(NSError **)error; {
    NSData *data = [self dataForAttribute:attribute atURL:url error:error];
    
    if (!data)
        return nil;
    
    id retval = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:error];
    
    return retval;
}
+ (BOOL)setObject:(id)object forAttribute:(NSString *)attribute atURL:(NSURL *)url error:(NSError **)error; {
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:object format:NSPropertyListXMLFormat_v1_0 options:0 error:error];
    
    return [self setData:data forAttribute:attribute atURL:url error:error];
}

+ (NSData *)dataForAttribute:(NSString *)attribute atURL:(NSURL *)url error:(NSError **)error; {
    NSParameterAssert(attribute);
    NSParameterAssert(url);
    
    size_t length = getxattr(url.path.fileSystemRepresentation, attribute.UTF8String, NULL, ULONG_MAX, 0, 0);
    
    if (length == ULONG_MAX ||
        length == -1) {
        
        if (error)
            *error = [self _localizedErrorForErrnoCode:errno];
        
        return nil;
    }
    
    NSMutableData *retval = [[NSMutableData alloc] initWithLength:length];
    size_t result = getxattr(url.path.fileSystemRepresentation, attribute.UTF8String, retval.mutableBytes, retval.length, 0, 0);
    
    if (result == -1) {
        if (error)
            *error = [self _localizedErrorForErrnoCode:errno];
        
        return nil;
    }
    
    return [retval copy];
}
+ (BOOL)setData:(NSData *)data forAttribute:(NSString *)attribute atURL:(NSURL *)url error:(NSError **)error; {
    NSParameterAssert(data);
    NSParameterAssert(attribute);
    NSParameterAssert(url);
    
    int result = setxattr(url.path.fileSystemRepresentation, attribute.UTF8String, data.bytes, data.length, 0, 0);
    
    if (result == -1) {
        if (error)
            *error = [self _localizedErrorForErrnoCode:errno];
        
        return NO;
    }
    
    return YES;
}

+ (NSError *)_localizedErrorForErrnoCode:(int)errnoCode; {
    NSString *localizedDescription = NSLocalizedStringFromTableInBundle(@"No description available", nil, WCFoundationBundle(), @"extended attributes manager no description available");
    
    switch (errnoCode) {
        case ENOATTR:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"The extended attribute does not exist", nil, WCFoundationBundle(), @"extended attributes manager ENOATTR");
            break;
        case ENOTSUP:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"The file system does not support extended attributes or has the feature disabled", nil, WCFoundationBundle(), @"extended attributes manager ENOTSUP");
            break;
        case ERANGE:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"value (as indicated by size) is too small to hold the extended attribute data", nil, WCFoundationBundle(), @"extended attributes manager ERANGE");
            break;
        case EPERM:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"The named attribute is not permitted for this type of object", nil, WCFoundationBundle(), @"extended attributes manager EPERM");
            break;
        case EINVAL:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"name is invalid or options has an unsupported bit set", nil, WCFoundationBundle(), @"extended attributes manager EINVAL");
            break;
        case EISDIR:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"path or fd do not refer to a regular file and the attribute in question is only applicable to files", nil, WCFoundationBundle(), @"extended attributes manager EISDIR");
            break;
        case ENOTDIR:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"A component of path 's prefix is not a directory", nil, WCFoundationBundle(), @"extended attributes manager ENOTDIR");
            break;
        case ENAMETOOLONG:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"The length of name exceeds XATTR_MAXNAMELEN UTF-8 bytes, or a component of path exceeds NAME_MAX characters, or the entire path exceeds PATH_MAX characters", nil, WCFoundationBundle(), @"extended attributes manager ENAMETOOLONG");
            break;
        case EACCES:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"Search permission is denied for a component of path or the attribute is not allowed to be read (e.g. an ACL prohibits reading the attributes of this file)", nil, WCFoundationBundle(), @"extended attributes manager EACCES");
            break;
        case ELOOP:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"Too many symbolic links were encountered in translating the pathname", nil, WCFoundationBundle(), @"extended attributes manager ELOOP");
            break;
        case EFAULT:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"path or name points to an invalid address", nil, WCFoundationBundle(), @"extended attributes manager EFAULT");
            break;
        case EIO:
            localizedDescription = NSLocalizedStringFromTableInBundle(@"An I/O error occurred while reading from or writing to the file system", nil, WCFoundationBundle(), @"extended attributes manager EIO");
            break;
        default:
            break;
    }
    
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:errnoCode userInfo:@{NSLocalizedDescriptionKey: localizedDescription}];
}

@end
