//
//  PioneerGoogleCast.m
//  ChromeCastStream
//
//  Created by Phil Scarfi on 11/30/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

#import "PioneerGoogleCast.h"
#import <GoogleCast/GoogleCast.h>

@interface PioneerGoogleCast () <GCKLoggerDelegate,GCKRemoteMediaClientListener>
@end

@implementation PioneerGoogleCast

-(void)registerWithAppID:(NSString *)appID debuggingEnabled:(BOOL)debugEnabled {
    self.debuggingEnabled = debugEnabled;
    GCKCastOptions *options =
    [[GCKCastOptions alloc] initWithDiscoveryCriteria:[[GCKDiscoveryCriteria alloc]initWithApplicationID:appID]];
    [GCKCastContext setSharedInstanceWithOptions:options];
    [GCKLogger sharedInstance].delegate = self;
}

-(void)cast:(NSString *)location {
    //METADATA
    GCKMediaMetadata *metadata =
    [[GCKMediaMetadata alloc] initWithMetadataType:GCKMediaMetadataTypeMovie];
    [metadata setString:@"Live Class" forKey:kGCKMetadataKeyTitle];
    [metadata setString:@"STUDIO" forKey:kGCKMetadataKeyStudio];

//    location = @"http://192.168.5.100:8080/hello/playlist.m3u8";
    location = @"http://192.168.5.55/index.m3u8";

    GCKMediaInformation *mediaInfo = [[GCKMediaInformation alloc]
                                      initWithContentID:location
                                      streamType:GCKMediaStreamTypeNone
                                      contentType:@"application/X-mpegURL"
                                      metadata:metadata
                                      streamDuration:INFINITY
                                      mediaTracks:nil
                                      textTrackStyle:nil
                                      customData:nil];
    
    GCKCastSession *session =
    [GCKCastContext sharedInstance].sessionManager.currentCastSession;
    if (session) {
        [session.remoteMediaClient addListener:self];
        [session.remoteMediaClient loadMedia: mediaInfo
                                    autoplay:YES];
    }
}

#pragma mark - GCKLoggerDelegate

- (void)logMessage:(NSString *)message atLevel:(GCKLoggerLevel)level fromFunction:(NSString *)function location:(NSString *)location {
    if (self.debuggingEnabled) {
        NSLog(@"%@  %@", function, message);
    }
}

- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didUpdateMediaStatus:(GCKMediaStatus *)mediaStatus {
    NSLog(@"Media Client Update  %@", mediaStatus);
}

- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didStartMediaSessionWithID:(NSInteger)sessionID {
    NSLog(@"Media Client started session");
}

@end
