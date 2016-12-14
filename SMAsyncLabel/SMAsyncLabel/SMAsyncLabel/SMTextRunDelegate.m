//
//  SMTextRunDelegate.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/12/13.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMTextRunDelegate.h"
static void DeallocCallback(void *ref) {
    SMTextRunDelegate *self = (__bridge_transfer SMTextRunDelegate *)(ref);
    self = nil;
}

static CGFloat GetAscentCallback(void *ref) {
    SMTextRunDelegate *self = (__bridge SMTextRunDelegate *)(ref);
    return self.ascent;
}

static CGFloat GetDecentCallback(void *ref) {
    SMTextRunDelegate *self = (__bridge SMTextRunDelegate *)(ref);
    return self.descent;
}

static CGFloat GetWidthCallback(void *ref) {
    SMTextRunDelegate *self = (__bridge SMTextRunDelegate *)(ref);
    return self.width;
}

@implementation SMTextRunDelegate

- (CTRunDelegateRef)CTRunDelegate {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks,0,sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = DeallocCallback;
    callbacks.getAscent = GetAscentCallback;
    callbacks.getDescent = GetDecentCallback;
    callbacks.getWidth = GetWidthCallback;
    return CTRunDelegateCreate(&callbacks, (__bridge_retained void *)([self copy]));
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeFloat:_ascent forKey:@"ascent"];
    [encoder encodeFloat:_descent forKey:@"descent"];
    [encoder encodeFloat:_width forKey:@"width"];
    [encoder encodeObject:_userInfo forKey:@"userInfo"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    _ascent = [decoder decodeFloatForKey:@"ascent"];
    _descent = [decoder decodeFloatForKey:@"descent"];
    _width = [decoder decodeFloatForKey:@"width"];
    _userInfo = [decoder decodeObjectForKey:@"userInfo"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) delegate = [self.class new];
    delegate.ascent = self.ascent;
    delegate.descent = self.descent;
    delegate.width = self.width;
    delegate.userInfo = self.userInfo;
    
    return delegate;
}
@end
