//
//  ViewController.m
//  JHContacts
//
//  Created by Kevin's MacBook Pro on 2016/11/29.
//  Copyright © 2016年 kevinBin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIActionSheetDelegate>

@property(nonatomic, copy)NSString *linkMobile;
@property (weak, nonatomic) IBOutlet UIButton *btnClick;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _contact = [[JHAddContacts alloc] init];
    
    _linkMobile = _btnClick.titleLabel.text;

    [_btnClick addTarget:self action:@selector(addContacts) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)addContacts {
    NSString *title = [NSString stringWithFormat:@"%@可能是电话号码",_linkMobile];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"呼叫",@"添加到联系人", nil];
    actionSheet.tag=2000;
    [actionSheet showInView:self.view];
}
#pragma mark - UIActionSheetDelegate弹出添加手机alert
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag==2000) {
        if(buttonIndex==0){
            NSURL *tmpUrl=[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",_linkMobile]];
            [[UIApplication sharedApplication]openURL:tmpUrl];
        }
        else if(buttonIndex==1){
            NSString *title = [NSString stringWithFormat:@"%@%@",_linkMobile, @"可能是电话号码"];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建新的联系人",@"添加到现有联系人", nil];
            actionSheet.tag=3000;
            [actionSheet showInView:self.view];
        }
    } else if (actionSheet.tag==3000){
        if (buttonIndex==0) {
            /* 添加新建联系人 */
            [_contact addNewContactMobileNum:_linkMobile controller:self];
        } else if (buttonIndex==1) {
            /* 添加到已有联系人 */
            [_contact addIsHaveContactMobileNum:_linkMobile controller:self];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
