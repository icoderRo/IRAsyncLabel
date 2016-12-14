//
//  SMTextRunDelegate.h
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/12/13.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
NS_ASSUME_NONNULL_BEGIN
/// Wrapper for CTRunDelegateRef.
@interface SMTextRunDelegate : NSObject<NSCopying, NSCoding>
@property (nullable,nonatomic,assign) CTRunDelegateRef CTRunDelegate;
@property (nonatomic,assign) CGFloat ascent;
@property (nonatomic,assign) CGFloat descent;
@property (nonatomic,assign) CGFloat width;
@property (nullable,nonatomic,strong) NSDictionary *userInfo;
@end

NS_ASSUME_NONNULL_END
