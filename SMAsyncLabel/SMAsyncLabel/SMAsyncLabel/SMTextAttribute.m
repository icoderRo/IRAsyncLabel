//
//  SMTextAttribute.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/12/8.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMTextAttribute.h"

@implementation SMTextAttacment
+ (instancetype)sm_attachmentWithContent:(id)content {
    SMTextAttacment *attachment = [[SMTextAttacment alloc] init];
    attachment.content = content;
    return attachment;
}

- (instancetype)init {
    if (self = [super init]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
    };
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SMTextAttacment *attachment = [[SMTextAttacment alloc] init];
    if ([self.content respondsToSelector:@selector(copy)]) {
        attachment.content = [self.content copy];
    } else {
        attachment.content = self.content;
    }
    
    attachment.contentMode = self.contentMode;
    attachment.contentInsets = self.contentInsets;
    attachment.userInfo = self.userInfo.copy;
    return attachment;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.content forKey:@"content"];
    [encoder encodeObject:[NSValue valueWithUIEdgeInsets:self.contentInsets] forKey:@"contentInsets"];
    [encoder encodeObject:self.userInfo forKey:@"userInfo"];
    [encoder encodeInteger:self.contentMode forKey:@"contentMode"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    _content = [decoder decodeObjectForKey:@"content"];
    _contentInsets = ((NSValue *)[decoder decodeObjectForKey:@"contentInsets"]).UIEdgeInsetsValue;
    _userInfo = [decoder decodeObjectForKey:@"userInfo"];
    _contentMode = [decoder decodeIntegerForKey:@"contentMode"];
    
    return self;
}
@end
