//
//  WCDocument.m
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//
//

#import "WCDocument.h"
#import "WCDocumentWindowController.h"

@interface WCDocument ()
@property (weak,nonatomic) WCDocumentWindowController *documentWindowController;
@end

@implementation WCDocument

- (void)makeWindowControllers {
    WCDocumentWindowController *documentWindowController = [[WCDocumentWindowController alloc] init];
    
    [self addWindowController:documentWindowController];
    
    [self setDocumentWindowController:documentWindowController];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return YES;
}
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return YES;
}

+ (BOOL)autosavesInPlace {
    return NO;
}
+ (BOOL)autosavesDrafts {
    return NO;
}

@end
