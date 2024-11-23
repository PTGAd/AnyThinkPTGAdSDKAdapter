//
//  ATTMBiddingManager.m
//  HeadBiddingDemo
//
//  Created by lix on 2022/10/20.
//

#import "ATPTGBiddingManager.h"

#import "ATPTGBiddingDelegate.h"

@interface ATPTGBiddingManager ()

@property (nonatomic, strong) NSMutableDictionary *bidingAdStorageAccessor;
@property (nonatomic, strong) NSMutableDictionary *bidingAdDelegate;

@end

@implementation ATPTGBiddingManager

+ (instancetype)sharedInstance {
    static ATPTGBiddingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ATPTGBiddingManager alloc] init];
        sharedInstance.bidingAdStorageAccessor = [NSMutableDictionary dictionary];
        sharedInstance.bidingAdDelegate = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (ATPTGBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        return [self.bidingAdStorageAccessor objectForKey:unitID];
    }
}

- (void)removeRequestItmeWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.bidingAdStorageAccessor removeObjectForKey:unitID];
    }
}

- (void)savaBiddingDelegate:(ATPTGBiddingDelegate *)delegate withUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.bidingAdDelegate setObject:delegate forKey:unitID];
    }
}

- (void)removeBiddingDelegateWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        if (unitID.length) {
            [self.bidingAdDelegate removeObjectForKey:unitID];
        }
    }
}

// 保存相应的竞价request，并向不同广告类型完成绑定
- (void)startWithRequestItem:(ATPTGBiddingRequest *)request {
    [self.bidingAdStorageAccessor setObject:request forKey:request.unitID];
    ATPTGBiddingDelegate *delegate = [[ATPTGBiddingDelegate alloc] init];
    delegate.unitID = request.unitID;
    [request.customObject setValue:delegate forKey:@"delegate"];
    [self savaBiddingDelegate:delegate withUnitID:request.unitID];
}


@end
