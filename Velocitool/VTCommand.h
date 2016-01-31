
#import <Cocoa/Cocoa.h>

@class VTRecord;

// This class represents a command that can be send to a connection in order to
// be executed by the device. Each command is just one char, takes a potential
// parameter, and returns a value or a list of values.
@interface VTCommand : NSObject

// True if flow control should be on for this command. No by default.
@property(nonatomic, readonly) BOOL flowControl;
// The character used for the command.
@property(nonatomic, readonly) unsigned char signal;
// The record describing the parameters to the command.
@property(nonatomic, readonly) VTRecord *parameter;
// The class capturing and decoding the results.
@property(nonatomic, readonly) Class resultClass;
// If the result is a list.
@property(nonatomic, readonly) BOOL returnsList;

// Creates a command returning a single value. resultClass should be a subclass
// of VTRecord.
+ commandWithSignal:(unsigned char)signal
          parameter:(VTRecord *)parameter
        resultClass:(Class)resultClass;
// Commands returning a list of results, note the 's' at the end of 'results'.
+ commandWithSignal:(unsigned char)signal
          parameter:(VTRecord *)parameter
       resultsClass:(Class)resultClass;
@end
