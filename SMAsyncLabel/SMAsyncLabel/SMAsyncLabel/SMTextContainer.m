//
//  SMTextContainer.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMTextContainer.h"

@interface SMTextContainer ()
@property (nonatomic,assign) CGSize size;
@property (nonatomic,strong) UIBezierPath *path;
@end

@implementation SMTextContainer
- (instancetype)init {
    
    if (self = [super init]) {
    }
    return self;
}

+ (instancetype)sm_textContainerWithSize:(CGSize)size {
   return [self sm_textContainerWithSize:size numberOfLines:0];
}

+ (instancetype)sm_textContainerWithSize:(CGSize)size numberOfLines:(NSUInteger)numberOfLines {
    SMTextContainer *textContainer = [[SMTextContainer alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    textContainer.path = path;
    textContainer.size = size;
    textContainer.numberOfLines = numberOfLines;
    return textContainer;
}
@end
