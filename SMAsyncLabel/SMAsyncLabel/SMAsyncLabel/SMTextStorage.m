//
//  SMTextStorage.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMTextStorage.h"

@interface SMTextStorage ()
@property (nonatomic, strong) SMTextLayout *textLayout;
@end

@implementation SMTextStorage
- (void)setText:(NSString *)text {
    if (!text || _text == text || [_text isEqualToString:text]) return;
    _text = text.copy;
    
    _attributeText = [[NSMutableAttributedString alloc] initWithString:_text attributes:nil];
    
    [self setupTextLayout];
}

- (void)setupTextLayout {
    if (!_attributeText) return;
    
    SMTextContainer *textContainer = [SMTextContainer SM_textContainerWithSize:CGSizeMake(100, 100)];
    _textLayout = [SMTextLayout SM_layoutWithContainer:textContainer text:self.attributeText];
}
@end
