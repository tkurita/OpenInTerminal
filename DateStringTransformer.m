//
//  DateStringTransformer.m
//  Open in Terminal
//
//  Created by 栗田 哲郎 on 2020/01/08.
//

#import "DateStringTransformer.h"

@implementation DateStringTransformer
+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:date];
}

@end
