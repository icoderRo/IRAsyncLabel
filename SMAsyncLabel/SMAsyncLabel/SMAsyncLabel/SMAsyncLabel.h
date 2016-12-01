//
//  SMAsyncLabel.h
//  SMAsyncLabel
//
//  Created by simon on 16/11/25.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMTextLayout.h"

@interface SMAsyncLabel : UIView

@property (nullable, nonatomic, copy) NSString *text;

@property (nullable, nonatomic, copy) NSAttributedString *attributedText;

/// get:not null
@property (null_resettable, nonatomic, strong) UIFont *font;

@property (null_resettable, nonatomic, strong) UIColor *textColor;
@end

@interface NSMutableAttributedString (SMText)
- (void)setFont:(nullable UIFont *)font range:(NSRange)range;
- (void)setTextColor:(nullable UIColor *)textColor range:(NSRange)range;
@end


