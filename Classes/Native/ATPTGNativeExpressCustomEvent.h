//
//  ATPTGNativeExpressCustomEvent.h
//  PTGSDKDemo
//
//  Created byttt on 2024/11/11.
//

#import <Foundation/Foundation.h>
#import <AnyThinkNative/AnyThinkNative.h>
#import <PTGAdSDK/PTGAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATPTGNativeExpressCustomEvent : ATNativeADCustomEvent<PTGNativeExpressAdDelegate>

@property(nonatomic,weak)UIViewController *currentController;
@property(nonatomic,assign)BOOL isReady;

@end

NS_ASSUME_NONNULL_END
