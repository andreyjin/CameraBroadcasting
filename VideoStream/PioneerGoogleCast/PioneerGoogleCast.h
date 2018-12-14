//
//  PioneerGoogleCast.h
//  ChromeCastStream
//
//  Created by Phil Scarfi on 11/30/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PioneerGoogleCast : NSObject
@property BOOL debuggingEnabled;
-(void)registerWithAppID:(NSString *)appID debuggingEnabled:(BOOL)debugEnabled;
-(void)cast:(NSString *)location;

@end

NS_ASSUME_NONNULL_END
