//
//  SMTextContainer.h
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, SMTextTruncationType) {
    /// No truncate.
    SMTextTruncationTypeNone = 0,
    SMTextTruncationTypeStart,
    SMTextTruncationTypeEnd,
    SMTextTruncationTypeMiddle,
};

@interface SMTextContainer : NSObject <NSCopying>

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) NSUInteger numberOfLines;
@property (nonatomic, assign) SMTextTruncationType truncationType;

+ (instancetype)sm_textContainerWithSize:(CGSize)size;
+ (instancetype)sm_textContainerWithSize:(CGSize)size numberOfLines:(NSUInteger)numberOfLines;
@end
