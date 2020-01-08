//
//  CheckIntervalTransformer.m
//  Open in Terminal
//
//  Created by 栗田 哲郎 on 2020/01/08.
//

#import "CheckIntervalTransformer.h"

@implementation CheckIntervalTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)reverseTransformedValue:(NSNumber *)selectedIndex
{
    switch ([selectedIndex intValue]) {
        case 0: // daily
            return @(86400);
            break;
        case 1: // weekly
            return @(604800);
            break;
        default: //monthly
            return @(18748800);
    }
}

- (id)transformedValue:(NSNumber *)interval
{
    int t = [interval intValue];
    if (t >= 18748800) {
        return @(2);
    } else if (t >= 604800) {
        return @(1);
    } else {
        return @(0);
    }
}

@end
