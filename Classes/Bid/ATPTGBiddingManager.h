//
//  ATTMBiddingManager.h
//  HeadBiddingDemo
//
//  Created by lix on 2022/10/20.
//

#import <Foundation/Foundation.h>

#import "ATPTGBiddingRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATPTGBiddingManager : NSObject

+ (instancetype)sharedInstance;

- (void)startWithRequestItem:(ATPTGBiddingRequest *)request;

- (ATPTGBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID;

- (void)removeRequestItmeWithUnitID:(NSString *)unitID;

- (void)removeBiddingDelegateWithUnitID:(NSString *)unitID;

@end

NS_ASSUME_NONNULL_END
