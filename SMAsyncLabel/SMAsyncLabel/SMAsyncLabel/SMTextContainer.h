//
//  SMTextContainer.h
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMTextContainer : NSObject

@property (nonatomic,strong,readonly) UIBezierPath *path;
@property (nonatomic,assign,readonly) CGSize size;

+ (instancetype)sm_textContainerWithSize:(CGSize)size;
@end
