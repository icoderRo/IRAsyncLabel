//
//  SMAttchmentViewController.m
//  SMAsyncLabel
//
//  Created by simon on 16/12/8.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMAttchmentViewController.h"
#import "SMAsyncLabel.h"
#import "Masonry.h"

@interface SMAttchmentViewController ()

@end

@implementation SMAttchmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    UIFont *font = [UIFont systemFontOfSize:18];
    {
        NSString *title = @"this is UIImage attachment";
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title]];
        
        UIImage *image = [UIImage imageNamed:@"cube"];
        NSMutableAttributedString *attach = [NSMutableAttributedString attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:font alignment:SMTextVerticalAlignmentTop];
        
        [text appendAttributedString:attach];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    {
        NSString *title = @"this is UIView attachment";
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title]];
        
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        view.backgroundColor = [UIColor grayColor];
        
        UISwitch *view = [[UISwitch alloc] init];
//        [view sizeToFit];
        NSMutableAttributedString *attach = [NSMutableAttributedString attachmentStringWithContent:view contentMode:UIViewContentModeCenter attachmentSize:view.frame.size alignToFont:font alignment:SMTextVerticalAlignmentCenter];
        
        [text appendAttributedString:attach];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    SMAsyncLabel *label = [[SMAsyncLabel alloc] init];
    label.numberOfLines = 0;
    label.attributedText = text;
    label.font = font;
    label.preferredMaxLayoutWidth = 400;
    label.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.height.equalTo(@(200));
    }];
    
}

@end
