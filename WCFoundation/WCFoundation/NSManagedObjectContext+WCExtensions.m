//
//  NSManagedObjectContext+WCExtensions.m
//  WCFoundation
//
//  Created by William Towe on 8/3/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSManagedObjectContext+WCExtensions.h"

@implementation NSManagedObjectContext (WCExtensions)

- (BOOL)WC_saveRecursively:(NSError **)error {
    __block BOOL retval = YES;
    __block NSError *blockError = nil;
    
    __weak typeof(self) wself = self;
    
    [self performBlockAndWait:^{
        __strong typeof(wself) sself = wself;
        
        NSError *outError;
        if ([sself save:&outError]) {
            NSManagedObjectContext *parentContext = sself.parentContext;
            
            while (parentContext) {
                [parentContext performBlockAndWait:^{
                    [parentContext save:NULL];
                }];
                
                parentContext = parentContext.parentContext;
            }
        }
        else {
            retval = NO;
            blockError = outError;
        }
    }];
    
    if (error)
        *error = blockError;
    
    return retval;
}

- (NSArray *)WC_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors; {
    return [self WC_fetchEntityNamed:entityName limit:0 offset:0 predicate:predicate sortDescriptors:sortDescriptors error:NULL];
}
- (NSArray *)WC_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error; {
    return [self WC_fetchEntityNamed:entityName limit:0 offset:0 predicate:predicate sortDescriptors:sortDescriptors error:error];
}
- (NSArray *)WC_fetchEntityNamed:(NSString *)entityName limit:(NSUInteger)limit predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error; {
    return [self WC_fetchEntityNamed:entityName limit:limit offset:0 predicate:predicate sortDescriptors:sortDescriptors error:error];
}
- (NSArray *)WC_fetchEntityNamed:(NSString *)entityName limit:(NSUInteger)limit offset:(NSUInteger)offset predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error; {
    NSParameterAssert(entityName);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    
    if (limit > 0)
        [fetchRequest setFetchLimit:limit];
    if (offset > 0)
        [fetchRequest setFetchOffset:offset];
    if (predicate)
        [fetchRequest setPredicate:predicate];
    if (sortDescriptors)
        [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [self executeFetchRequest:fetchRequest error:error];
}

@end
