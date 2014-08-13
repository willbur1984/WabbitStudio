//
//  WCTextFinderOptions.m
//  WCEdit
//
//  Created by William Towe on 8/10/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCTextFinderOptions.h"

@implementation WCTextFinderOptions
#pragma mark *** Subclass Overrides ***
- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setWrap:YES];
    
    return self;
}
#pragma mark *** Public Methods ***
+ (NSString *)localizedStringForMatchingStyle:(WCTextFinderOptionsMatchingStyle)matchingStyle; {
    switch (matchingStyle) {
        case WCTextFinderOptionsMatchingStyleRegularExpression:
            return NSLocalizedString(@"Regular Expression", @"text finder options matching style regular expression");
        case WCTextFinderOptionsMatchingStyleTextual:
            return NSLocalizedString(@"Textual", @"text finder options matching style textual");
        default:
            return nil;
    }
}
+ (NSString *)localizedStringForMatchingType:(WCTextFinderOptionsMatchingType)matchingType; {
    switch (matchingType) {
        case WCTextFinderOptionsMatchingTypeContains:
            return NSLocalizedString(@"contain search term", @"text finder options matching type contains");
        case WCTextFinderOptionsMatchingTypeEndsWith:
            return NSLocalizedString(@"ends with search term", @"text finder options matching type ends with");
        case WCTextFinderOptionsMatchingTypeFullWord:
            return NSLocalizedString(@"match search term", @"text finder options matching type full word");
        case WCTextFinderOptionsMatchingTypeStartsWith:
            return NSLocalizedString(@"starts with search term", @"text finder options matching type starts with");
        default:
            return nil;
    }
}

@end
