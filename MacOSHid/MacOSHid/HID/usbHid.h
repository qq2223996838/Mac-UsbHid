//
//  usbHid.h
//  MacOSHid
//
//  Created by Smile on 2019/3/21.
//  Copyright © 2019年 mac. All rights reserved.

/*
 ⚠️注意usbHid.m
 ID 信息需要改成通讯设备的ID
 查询-> 导航🍎图标 -> 概览 -> 系统报告 -> USB  -> 对应设备信息里面
 const long vendorID = 0x0483;
 const long productID = 0x5703;
 
 如有帮助不解敬请关注简书：隐身人
 https://www.jianshu.com/u/86cc50fb916f
 */

#import <Foundation/Foundation.h>
#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDKeys.h>

@protocol UsbHidDelegate <NSObject>
@optional

//收到数据返回 recvData(具体数据) reportLength(数据长度)
- (void)usbhidDidRecvData:(uint8_t*)recvData length:(CFIndex)reportLength;

//设备插入/设备拔出
- (void)usbhidDidMatch;
- (void)usbhidDidRemove;
@end

@interface usbHid : NSObject
{
    IOHIDManagerRef managerRef;
    IOHIDDeviceRef deviceRef;
}

+ (usbHid *)sharedManager;

//连接设备
- (void)connectHID;

//发送数据
- (void)sendData:(unsigned char *)outbuffer;

//数据返回代理
@property(nonatomic,strong)id<UsbHidDelegate> delegate;

//得到当前接口设备管理对象/更新新接口设备管理对象
- (IOHIDManagerRef)getManageRef;
- (void)setManageRef:(IOHIDManagerRef)ref;

//得到当前设备/更新新的设备
- (IOHIDDeviceRef)getDeviceRef;
- (void)setDeviceRef:(IOHIDDeviceRef)ref;


@end
