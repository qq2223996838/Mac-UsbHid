//
//  usbHid.m
//  MacOSHid
//
//  Created by Smile on 2019/3/21.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "usbHid.h"

@implementation usbHid

static usbHid *_sharedManager = nil;

@synthesize delegate;

+(usbHid *)sharedManager {
    @synchronized( [usbHid class] ){
        if(!_sharedManager)
            _sharedManager = [[self alloc] init];
        return _sharedManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized ([usbHid class]){
        NSAssert(_sharedManager == nil,
                 @"Attempted to allocated a second instance");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

#pragma mark - 初始化
- (id)init {
    self = [super init];
    if (self) {
        managerRef = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
        IOHIDManagerScheduleWithRunLoop(managerRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
        IOReturn ret = IOHIDManagerOpen(managerRef, 0L);
        if (ret != kIOReturnSuccess) {
            NSLog(@"打开设备失败!");
            return self;
        }else{
            NSLog(@"打开设备成功!");
        }
        
        const long vendorID = 0x0483;
        const long productID = 0x5703;
        NSMutableDictionary* dict= [NSMutableDictionary dictionary];
        [dict setValue:[NSNumber numberWithLong:productID] forKey:[NSString stringWithCString:kIOHIDProductIDKey encoding:NSUTF8StringEncoding]];
        [dict setValue:[NSNumber numberWithLong:vendorID] forKey:[NSString stringWithCString:kIOHIDVendorIDKey encoding:NSUTF8StringEncoding]];
        IOHIDManagerSetDeviceMatching(managerRef, (__bridge CFMutableDictionaryRef)dict);
        
        IOHIDManagerRegisterDeviceMatchingCallback(managerRef, &Handle_DeviceMatchingCallback, NULL);
        IOHIDManagerRegisterDeviceRemovalCallback(managerRef, &Handle_DeviceRemovalCallback, NULL);
        
        NSSet* allDevices = (__bridge NSSet*)(IOHIDManagerCopyDevices(managerRef));
        NSArray* deviceRefs = [allDevices allObjects];
        if (deviceRefs.count==0) {
            NSLog(@"初始化 - 连接设备  设备列表  -- %lu",(unsigned long)deviceRefs.count);
        }
    }
    return self;
}

#pragma mark - 注册 Hid 方法
static void Handle_DeviceMatchingCallback(void *inContext,IOReturn inResult,void *inSender,IOHIDDeviceRef inIOHIDDeviceRef) {
    [[usbHid sharedManager] setDeviceRef:inIOHIDDeviceRef];
    char *inputbuffer = malloc(64);
    IOHIDDeviceRegisterInputReportCallback([[usbHid sharedManager]getDeviceRef], (uint8_t*)inputbuffer, 64, inputCallback, NULL);
    NSLog(@"%p \n设备插入,现在usb设备数量:%ld",(void *)inIOHIDDeviceRef,USBDeviceCount(inSender));
    [[[usbHid sharedManager] delegate] usbhidDidMatch];
}

static void Handle_DeviceRemovalCallback(void *inContext,IOReturn inResult,void *inSender,IOHIDDeviceRef inIOHIDDeviceRef) {
    [[usbHid sharedManager] setDeviceRef:nil];
    NSLog(@"%p \n设备拔出,现在usb设备数量:%ld",(void *)inIOHIDDeviceRef,USBDeviceCount(inSender));
    [[[usbHid sharedManager] delegate] usbhidDidRemove];
}

static long USBDeviceCount(IOHIDManagerRef HIDManager){
    CFSetRef devSet = IOHIDManagerCopyDevices(HIDManager);
    if(devSet)
        return CFSetGetCount(devSet);
    return 0;
}

#pragma mark - 获取设备列表/连接设备
- (void)connectHID {
    NSSet* allDevices = (__bridge NSSet*)(IOHIDManagerCopyDevices(managerRef));
    NSArray* deviceRefs = [allDevices allObjects];
    
    // 这里默认连接 设备列表第 一 个
    deviceRef = (deviceRefs.count)?(__bridge IOHIDDeviceRef)[deviceRefs objectAtIndex:0]:nil;
    
    NSLog(@"连接设备  设备列表  -- %lu",(unsigned long)deviceRefs.count);
}


#pragma mark - 发送数据
- (void)sendData:(unsigned char *)outbuffer {
    
//    NSData *data = [[NSData alloc] initWithBytes:outbuffer length:7];
//    NSLog(@"发送数据内容： %@",data);
    
    if (!deviceRef) {
        NSLog(@"没有找到设备 - ");
        return ;
    }
    IOReturn ret = IOHIDDeviceSetReport(deviceRef, kIOHIDReportTypeOutput, 0, (uint8_t*)outbuffer, sizeof(outbuffer));
    if (ret != kIOReturnSuccess) {
        NSLog(@"发送数据失败!");
    }else{
        NSLog(@"发送数据成功!");
    }
}

#pragma mark - 接收数据
static void inputCallback(void* context, IOReturn result, void* sender, IOHIDReportType type, uint32_t reportID, uint8_t *report,CFIndex reportLength) {
    
    [[[usbHid sharedManager] delegate] usbhidDidRecvData:report length:reportLength];
    
}

#pragma mark - Setter and Getter

- (IOHIDManagerRef)getManageRef {
    return managerRef;
}

- (void)setManageRef:(IOHIDManagerRef)ref {
    managerRef = ref;
}

- (IOHIDDeviceRef)getDeviceRef {
    return deviceRef;
}

- (void)setDeviceRef:(IOHIDDeviceRef)ref {
    deviceRef = ref;
}

- (void)dealloc {
    IOReturn ret = IOHIDDeviceClose(deviceRef, 0L);
    if (ret == kIOReturnSuccess) {
        deviceRef = nil;
    }
    ret = IOHIDManagerClose(managerRef, 0L);
    if (ret == kIOReturnSuccess) {
        managerRef = nil;
    }
}

@end
