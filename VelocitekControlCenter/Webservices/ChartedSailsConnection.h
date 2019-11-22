//
//  ChartedSailsConnection.h
//  Velocitek Control Center
//
//  Created by Thomas Sarlandie on 11/20/19.
//

#ifndef ChartedSailsConnection_h
#define ChartedSailsConnection_h

@protocol ChartedSailsConnectionDelegate

@end

@interface ChartedSailsConnection : NSObject
// Returns a singleton, there could be only one.
+ connection;

- (void) uploadTrack:(NSURL *_Nonnull) filepath completionHandler:(void (^_Nonnull)(NSURL * _Nullable redirectURL, NSString * _Nullable error))handler;

@end


#endif /* ChartedSailsConnection_h */
