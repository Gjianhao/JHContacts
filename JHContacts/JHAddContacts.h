//
//  JHAddContacts.h
//  JHContacts
//
//  Created by Kevin's MacBook Pro on 2016/11/29.
//  Copyright © 2016年 kevinBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface JHAddContacts : UIViewController<CNContactPickerDelegate,CNContactViewControllerDelegate,ABNewPersonViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate>

/**
 *  电话号码
 */
@property(nonatomic, strong) NSString *linkMobile;

/**
 *  创建联系人的通讯录控制器
 */
@property(nonatomic, strong)CNContactViewController *controller;

/**
 *  聊天界面
 */
@property(nonatomic, weak)id chatVC;

/**
 *  添加新联系人
 *
 *  @param mobileNum 号码
 */
- (void)addNewContactMobileNum:(NSString *)mobileNum controller:(id)chat;

/**
 *  添加到已有联系人中
 *
 *  @param mobileNum 号码
 */
- (void)addIsHaveContactMobileNum:(NSString *)mobileNum controller:(id)chat;

@end
