// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bookmark.h instead.

#import <CoreData/CoreData.h>


extern const struct BookmarkAttributes {
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *range;
} BookmarkAttributes;

extern const struct BookmarkRelationships {
} BookmarkRelationships;

extern const struct BookmarkFetchedProperties {
} BookmarkFetchedProperties;



@class NSValue;

@interface BookmarkID : NSManagedObjectID {}
@end

@interface _Bookmark : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BookmarkID*)objectID;





@property (nonatomic, strong) NSNumber* location;



@property int64_t locationValue;
- (int64_t)locationValue;
- (void)setLocationValue:(int64_t)value_;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSValue* range;



//- (BOOL)validateRange:(id*)value_ error:(NSError**)error_;






@end

@interface _Bookmark (CoreDataGeneratedAccessors)

@end

@interface _Bookmark (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveLocation;
- (void)setPrimitiveLocation:(NSNumber*)value;

- (int64_t)primitiveLocationValue;
- (void)setPrimitiveLocationValue:(int64_t)value_;




- (NSValue*)primitiveRange;
- (void)setPrimitiveRange:(NSValue*)value;




@end
