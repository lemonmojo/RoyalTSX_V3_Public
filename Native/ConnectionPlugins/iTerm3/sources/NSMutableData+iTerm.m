//
//  NSMutableData+iTerm.m
//  iTerm
//
//  Created by George Nachman on 3/10/14.
//
//

#import "NSMutableData+iTerm.h"

@implementation NSMutableData (iTerm)

- (void)appendBytes:(unsigned char *)bytes length:(int)length excludingCharacter:(char)exclude {
    int i;
    int lastIndex = 0;
    for (i = 0; i < length; i++) {
        if (bytes[i] == exclude) {
            if (i > lastIndex) {
                [self appendBytes:bytes + lastIndex length:i - lastIndex];
            }
            lastIndex = i + 1;
        }
    }
    if (i > lastIndex) {
        [self appendBytes:bytes + lastIndex length:i - lastIndex];
    }
}

@end
