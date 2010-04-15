
#import <Cocoa/Cocoa.h>

@class VTRecord;
@class VTConnection;

@interface VTCommand : NSObject {
    unsigned char _signal;
    VTRecord *_parameter;
    Class _resultClass;
    BOOL _isList;
}
+ commandWithSignal:(unsigned char)signal parameter:(VTRecord *)parameter resultClass:(Class)resultClass;
+ commandWithSignal:(unsigned char)signal parameter:(VTRecord *)parameter resultsClass:(Class)resultClass;
- (BOOL)flowControl;
- (unsigned char)signal;
- (VTRecord *)parameter;
- (Class)resultClass;
- (BOOL)returnsList;

@end



