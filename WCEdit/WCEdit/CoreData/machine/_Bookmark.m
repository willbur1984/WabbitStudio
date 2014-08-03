// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bookmark.m instead.

#import "_Bookmark.h"

const struct BookmarkAttributes BookmarkAttributes = {
	.lineStartIndex = @"lineStartIndex",
	.range = @"range",
};

const struct BookmarkRelationships BookmarkRelationships = {
};

const struct BookmarkFetchedProperties BookmarkFetchedProperties = {
};

@implementation BookmarkID
@end

@implementation _Bookmark

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Bookmark";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:moc_];
}

- (BookmarkID*)objectID {
	return (BookmarkID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"lineStartIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lineStartIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic lineStartIndex;



- (int64_t)lineStartIndexValue {
	NSNumber *result = [self lineStartIndex];
	return [result longLongValue];
}

- (void)setLineStartIndexValue:(int64_t)value_ {
	[self setLineStartIndex:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveLineStartIndexValue {
	NSNumber *result = [self primitiveLineStartIndex];
	return [result longLongValue];
}

- (void)setPrimitiveLineStartIndexValue:(int64_t)value_ {
	[self setPrimitiveLineStartIndex:[NSNumber numberWithLongLong:value_]];
}





@dynamic range;











@end
