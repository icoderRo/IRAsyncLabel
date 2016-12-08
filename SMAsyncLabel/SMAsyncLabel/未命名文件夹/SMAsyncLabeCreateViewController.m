//
//  SMAsyncLabeCreateViewController.m
//  SMAsyncLabel
//
//  Created by simon on 16/12/5.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMAsyncLabeCreateViewController.h"
#import "SMAsyncLabel.h"
#import "Masonry.h"
#import "SMTextContainer.h"
@interface SMAsyncLabeCreateViewController ()

@end

@implementation SMAsyncLabeCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *test = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd";
    NSString *test1 = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd    sdafasgdhfjg!!!!!!!!!!!!Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd    sdafasgdhfjg!!!!!!!!!!!!";
    NSString *test2 = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd大师傅 Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd大师傅";
    
    
    // method 一:
    SMAsyncLabel *label = [[SMAsyncLabel alloc] initWithFrame:CGRectMake(10, 70, 200, 300)];
    label.font = [UIFont systemFontOfSize:20];
    label.text = test;
    label.lineSpacing = 10;
    label.textColor = [UIColor greenColor];
    label.backgroundColor = [UIColor redColor];
    [self.view addSubview:label];
    
    
    
    { // method 二:
        SMAsyncLabel *label1 = [[SMAsyncLabel alloc] init];
        label1.backgroundColor = [UIColor yellowColor];
        label1.textColor = [UIColor blueColor];
        label1.text = test1;
        label1.font = [UIFont systemFontOfSize:22];
        [self.view addSubview:label1];
        
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right).offset(0);
            make.top.equalTo(label).offset(10);
            make.width.equalTo(@(200));
            make.bottom.equalTo(self.view).offset(-200);
        }];
    }
    
    
    { // method 三:
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] initWithString:test1];
            [attrs setTextColor:[UIColor whiteColor] range:NSMakeRange(0, attrs.length)];
            [attrs setFont:[UIFont systemFontOfSize:20] range:NSMakeRange(0, attrs.length)];
            [attrs setTextAlignment:NSTextAlignmentCenter range:NSMakeRange(0, attrs.length)];
            
            SMTextContainer *textContainer = [SMTextContainer sm_textContainerWithSize:CGSizeMake(200, 200)];
            textContainer.numberOfLines = 8;
            SMTextLayout *textLayout = [SMTextLayout sm_layoutWithContainer:textContainer text:attrs];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                SMAsyncLabel *label = [SMAsyncLabel new];
                label.textLayout = textLayout;
                label.frame = CGRectMake(10, 400,textLayout.size.width, textLayout.size.height);
                label.backgroundColor = [UIColor grayColor];
                [self.view addSubview:label];
            });
            
        });
    }
    
    
    { // method 四:
        SMAsyncLabel *label = [[SMAsyncLabel alloc] init];
        
        label.font = [UIFont systemFontOfSize:22];
        label.preferredMaxLayoutWidth = 200;
        label.text = test2;
        label.lineSpacing = 30;
        label.characterSpacing = 5;
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 5;
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor greenColor];
        label.alpha = 0.99;
        [self.view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    }
    
}

@end
