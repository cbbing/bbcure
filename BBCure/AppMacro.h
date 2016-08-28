//
//  AppMacro.h
//  numberology
//  app相关的宏定义
//
//  Created by cbb on 14-2-26.
//  Copyright (c) 2014年 cbb. All rights reserved.
//

#ifndef numberology_AppMacro_h
#define numberology_AppMacro_h

#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self;

#define ACTIVIE_PASSCODE @"is_active_passcode"
#define PASSCODE @"user_passcode"
#define BKPasscodeKeychainServiceName @"BKPasscodeSampleService"

#endif
