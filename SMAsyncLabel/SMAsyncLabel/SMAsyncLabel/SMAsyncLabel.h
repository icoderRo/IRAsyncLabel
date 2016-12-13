//
//  SMAsyncLabel.h
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/25.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMTextLayout.h"
#import "SMTextAttribute.h"

@interface SMAsyncLabel : UIView

@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSAttributedString *attributedText;

/// get:not null
@property (null_resettable, nonatomic, strong) UIFont *font;
@property (null_resettable, nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSUInteger numberOfLines;
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode; // error
@property (nonatomic, assign) CGFloat lineSpacing; // must set after test / attributedText
@property (nonatomic, assign) unichar characterSpacing; // must set after test / attributedText

@property (nullable, nonatomic, strong) SMTextLayout *textLayout;
@end

@interface NSMutableAttributedString (SMText)
- (void)setFont:(nullable UIFont *)font range:(NSRange)range;
- (void)setTextColor:(nullable UIColor *)textColor range:(NSRange)range;
- (void)setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range;
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;
- (void)setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range;
- (void)setCharacterSpacing:(unichar)characterSpacing range:(NSRange)range;
//- (void)setTextAttachment:(SMTextAttacment *)textAttachment range:(NSRange)range;
+ (NSMutableAttributedString *)attachmentStringWithContent:(id)content
                                               contentMode:(UIViewContentMode)contentMode
                                                  userInfo:(NSDictionary *)userInfo
                                                     width:(CGFloat)width
                                                    ascent:(CGFloat)ascent
                                                   descent:(CGFloat)descent;
@end


