//
//  SMTextStorage.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMTextStorage.h"

@interface SMTextStorage ()

@end

@implementation SMTextStorage
#pragma mark - init
+ (SMTextStorage *)sm_textStorageWithText:(NSString *)text frame:(CGRect)frame {
    SMTextStorage *textStorage = [[SMTextStorage alloc] initWithFrame:frame];
    SMTextContainer *textContainer = [SMTextContainer sm_textContainerWithSize:frame.size];
    
    textStorage->_attributeText = [[NSAttributedString alloc] initWithString:text attributes:nil];
    textStorage->_textLayout = [SMTextLayout sm_layoutWithContainer:textContainer text:textStorage.attributeText];
    
    return textStorage;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        self.frame = frame;
    }
    return self;
}

- (void)setText:(NSString *)text {
    if (!text || _text == text || [_text isEqualToString:text]) return;
    _text = text.copy;
    
    _attributeText = [[NSAttributedString alloc] initWithString:_text attributes:nil];
    
    [self setupTextLayout];
}

- (void)setupTextLayout {
    if (!_attributeText) return;
    
    SMTextContainer *textContainer = [SMTextContainer sm_textContainerWithSize:self.frame.size];
    _textLayout = [SMTextLayout sm_layoutWithContainer:textContainer text:self.attributeText];
}
@end
