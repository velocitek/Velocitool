//
//  ChartedSailsConnection.m
//  Velocitek Control Center
//
//  Created by Thomas Sarlandie on 11/20/19.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ChartedSailsConnection.h"

@import CocoaLumberjack;

@implementation ChartedSailsConnection

+ connection {
    static ChartedSailsConnection *the_one_true_instance = nil;
    if (!the_one_true_instance) {
        the_one_true_instance = [[ChartedSailsConnection alloc] init];
    }
    return the_one_true_instance;
}

- (void) uploadTrack:(NSURL *) filePath completionHandler:(void (^)(NSURL * _Nullable redirectURL, NSString * _Nullable error))handler {
    DDLogInfo(@"Upload track to ChartedSails: %@", [filePath path]);
    
    NSString *urlString = @"https://api.chartedsails.com/upload";

    // - (void)someMethodThatTakesABlock:(returnType (^nullability)(parameterTypes))blockName;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            DDLogVerbose(@"Appending file data: %@ %llu", [filePath path], [[[NSFileManager defaultManager] attributesOfItemAtPath:[filePath path] error:nil] fileSize]);
            
        NSError *error;
        if (![formData appendPartWithFileURL:filePath name:@"file" fileName:filePath.lastPathComponent mimeType:@"text/xml" error:&error]) {
            DDLogWarn(@"Unable to attach file (%@) to upload request: %@", [filePath path], error);
        }
    } error:nil];

    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          DDLogVerbose(@"progress: %f", uploadProgress.fractionCompleted);
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    NSDictionary *responseDict = responseObject;
                    if (error) {
                        DDLogError(@"Error: nsError=%@ responseObject=%@ response['error']=%@", error, responseObject, [responseDict objectForKey:@"error"]);
                        
                        NSString *userErrorMessage = [error localizedDescription];
                        if (responseObject != nil && [responseDict objectForKey:@"error"]) {
                            userErrorMessage =[responseDict objectForKey:@"error"];
                        }
                        handler(nil, userErrorMessage);
                      } else {
                          DDLogInfo(@"%@ %@ %@", response, responseObject, [responseDict objectForKey:@"redirect"]);
                          
                          NSString *redirect = [responseDict objectForKey:@"redirect"];
                          if (!redirect) {
                              handler(nil, @"Unexpected reply from server. No redirect or error.");
                          }
                          else {
                              NSURL *redirectURL = [NSURL URLWithString:redirect];
                              handler(redirectURL, nil);
                          }
                      }
                  }];

    [uploadTask resume];
}

@end
