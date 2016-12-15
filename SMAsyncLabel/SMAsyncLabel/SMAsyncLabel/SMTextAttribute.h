//
//  SMTextAttribute.h
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/12/8.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SMTextVerticalAlignment) {
    SMTextVerticalAlignmentTop =    0, ///< Top alignment.
    SMTextVerticalAlignmentCenter = 1, ///< Center alignment.
    SMTextVerticalAlignmentBottom = 2, ///< Bottom alignment.
};

UIKIT_EXTERN NSString *const SMTextAttachmentAttributeName;
UIKIT_EXTERN NSString *const SMTextAttachmentToken;

@interface SMTextAttachment : NSObject<NSCopying, NSCoding>

+ (instancetype)sm_attachmentWithContent:(nullable id)content;
@property (nullable, nonatomic, strong) id content;
@property (nonatomic) UIViewContentMode contentMode;
@property (nonatomic) UIEdgeInsets contentInsets;               
@property (nullable, nonatomic, strong) NSDictionary *userInfo;

@end

