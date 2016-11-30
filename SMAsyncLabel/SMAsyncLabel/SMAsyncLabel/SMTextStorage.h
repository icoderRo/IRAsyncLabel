//
//  SMTextStorage.h
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTextLayout.h"
#import <UIKit/UIKit.h>

@interface SMTextStorage : NSObject
@property (nonatomic, strong, readonly) SMTextLayout *textLayout;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributeText;
@property (nonatomic,assign) CGRect frame;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (id)initWithFrame:(CGRect)frame;
+ (SMTextStorage *)sm_textStorageWithText:(NSString *)text frame:(CGRect)frame;
@end
