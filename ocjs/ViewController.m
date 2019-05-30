//
//  ViewController.m
//  ocjs
//
//  Created by ZD on 2019/5/30.
//  Copyright © 2019 ZD. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = false;
    
    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat margin = 10;
    UIButton *btn_left = [[UIButton alloc] initWithFrame:CGRectMake(margin, 50, (rect.size.width - 3 * margin)/2, 50)];
    btn_left.backgroundColor = [UIColor redColor];
    [btn_left setTitle:@"Start" forState:(UIControlStateNormal)];
    [btn_left addTarget:self action:@selector(btn_leftClick) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *btn_right = [[UIButton alloc] initWithFrame:CGRectMake(2 * margin + (rect.size.width - 3 * margin)/2, 50, (rect.size.width - 3 * margin)/2, 50)];
    btn_right.backgroundColor = [UIColor greenColor];
    [btn_right setTitle:@"End" forState:(UIControlStateNormal)];
    [btn_right addTarget:self action:@selector(btn_rightClick) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:btn_left];
    [self.view addSubview:btn_right];
    
}

- (void)btn_leftClick{
    
}

- (void)btn_rightClick{
     SecondViewController *secondVC = [SecondViewController new];
    [self.navigationController pushViewController:secondVC animated:true];
}


@end

