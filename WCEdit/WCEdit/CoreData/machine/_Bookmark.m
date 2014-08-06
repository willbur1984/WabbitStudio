// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bookmark.m instead.

#import "_Bookmark.h"

const struct BookmarkAttributes BookmarkAttributes = {
	.location = @"location",
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
	
	if ([key isEqualToString:@"locationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"location"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic location;



- (int64_t)locationValue {
	NSNumber *result = [self location];
	return [result longLongValue];
}

- (void)setLocationValue:(int64_t)value_ {
	[self setLocation:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveLocationValue {
	NSNumber *result = [self primitiveLocation];
	return [result longLongValue];
}

- (void)setPrimitiveLocationValue:(int64_t)value_ {
	[self setPrimitiveLocation:[NSNumber numberWithLongLong:value_]];
}





@dynamic range;











@end
