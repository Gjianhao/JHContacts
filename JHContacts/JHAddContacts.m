//
//  JHAddContacts.m
//  JHContacts
//
//  Created by Kevin's MacBook Pro on 2016/11/29.
//  Copyright © 2016年 kevinBin. All rights reserved.
//

#import "JHAddContacts.h"

@interface JHAddContacts ()

@end

@implementation JHAddContacts

- (void)addNewContactMobileNum:(NSString *)mobileNum controller:(id)chat{
    
    _linkMobile = mobileNum;
    _chatVC = chat;
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9.0) {
        //1.创建Contact对象，须是可变
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        //2.为contact赋值
        [self setValueForContact:contact existContect:NO];
        //3.创建新建联系人页面
        _controller = [CNContactViewController viewControllerForNewContact:contact];
        _controller.navigationItem.title = @"新建联系人";
        //代理内容根据自己需要实现
        _controller.delegate = self;
        //4.跳转
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_controller];
        [_chatVC presentViewController:nav animated:YES completion:nil];

    } else {
        ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
        ABRecordRef newPerson = ABPersonCreate();
        ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        CFErrorRef error = NULL;
        
        ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)(mobileNum), kABPersonPhoneMobileLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiValue , &error);
        picker.displayedPerson = newPerson;
        picker.newPersonViewDelegate = self;
        picker.navigationItem.title = @"新建联系人";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
        [_chatVC presentViewController:nav animated:YES completion:nil];
        CFRelease(newPerson);
        CFRelease(multiValue);
    }
    
}

- (void)addIsHaveContactMobileNum:(NSString *)mobileNum controller:(id)chat{
    
    _linkMobile = mobileNum;
    _chatVC = chat;
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9.0) {
        //1.跳转到联系人选择页面，注意这里没有使用UINavigationController
        CNContactPickerViewController *controller = [[CNContactPickerViewController alloc] init];
        controller.delegate = self;
        [_chatVC presentViewController:controller animated:YES completion:nil];
    } else {
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        [_chatVC presentViewController:picker animated:YES completion:nil];
    }
    
}

- (void)saveAddressBookByMobileNumIniOS9LaterDidCompleteWithContact:contact {
    //3.copy一份可写的Contact对象，不能用alloc
    CNMutableContact *con = [contact mutableCopy];
    //4.为contact赋值
    [self setValueForContact:con existContect:YES];
    //5.跳转到新建联系人页面
    CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:con];
    controller.delegate = self;
    controller.navigationItem.title = @"新建联系人";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [_chatVC presentViewController:nav animated:YES completion:nil];
}

- (void)saveAddressBookDidSelectPerson:(ABRecordRef)person{
    
    /* 获取联系人电话 */
    ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSMutableArray *phones = [NSMutableArray array];
    for (CFIndex i = 0; i < ABMultiValueGetCount(phoneMulti); i++) {
        NSString *aPhone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneMulti, i);
        NSString *aLabel = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(phoneMulti, i);
        NSLog(@"手机号标签:%@ 手机号:%@",aLabel,aPhone);
        [phones addObject:aPhone];
        [phones addObject:aLabel];
    }
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    CFErrorRef error = NULL;
    
    ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)(_linkMobile), kABPersonPhoneMobileLabel, NULL);
    for (int i = 0; i<[phones count]; i+=2) {
        
        ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)([phones objectAtIndex:i]), (__bridge CFStringRef)([phones objectAtIndex:i+1]), NULL);
    }
    ABRecordSetValue(person, kABPersonPhoneProperty, multiValue, &error);
    picker.displayedPerson = person;
    picker.newPersonViewDelegate = self;
    picker.navigationItem.title = @"新建联系人";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    [_chatVC presentViewController:nav animated:YES completion:nil];
    CFRelease(multiValue);
    CFRelease(phoneMulti);
    
}

#pragma mark - iOS9以前的ABNewPersonViewController代理方法
/* 该代理方法可dismiss新添联系人页面 */
-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    
    [_chatVC dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - iOS9以前的ABPeoplePickerNavigationController的代理方法
-(void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    
    [_chatVC dismissViewControllerAnimated:YES completion:^{
        [self saveAddressBookDidSelectPerson:person];
    }];
}

#pragma mark - iOS9以后的CNContactViewControllerDelegate代理方法
/* 该代理方法可dismiss新添联系人页面 */
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(CNContact *)contact {
    
    [_chatVC dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - iOS9以后的CNContactPickerDelegate的代理方法
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    
    [_chatVC dismissViewControllerAnimated:YES completion:^{
        
        [self saveAddressBookByMobileNumIniOS9LaterDidCompleteWithContact:contact];
    }];
}

/**
 *  设置要保存的contact对象
 *
 *  @param contact 联系人
 *  @param exist   是否需要重新创建
 */
- (void)setValueForContact:(CNMutableContact *)contact existContect:(BOOL)exist {
    //电话
    CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:_linkMobile]];
    if (!exist) {
        contact.phoneNumbers = @[phoneNumber];
    } else {
        //现有联系人情况
        if ([contact.phoneNumbers count] >0) {
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithArray:contact.phoneNumbers];
            [phoneNumbers addObject:phoneNumber];
            contact.phoneNumbers = phoneNumbers;
        }else{
            contact.phoneNumbers = @[phoneNumber];
        }
    }
}

@end
