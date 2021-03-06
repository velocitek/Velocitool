#import "VTCommand.h"
#import "VTGlobals.h"
#import "VTRecord.h"

@interface VTCommand ()
// Private Designated initializer.
- (instancetype)initWithSignal:(unsigned char)signal
                     parameter:(VTRecord *)parameter
                   resultClass:(Class)resultClass
                        isList:(BOOL)yn;
@end

@implementation VTCommand
@synthesize signal = _signal;
@synthesize parameter = _parameter;
@synthesize resultClass = _resultClass;
@synthesize returnsList = _returnsList;

#pragma mark - Class methods.

+ commandWithSignal:(unsigned char)signalChar
          parameter:(VTRecord *)parameter
        resultClass:(Class)resultClass {
  return [[self alloc] initWithSignal:signalChar
                             parameter:parameter
                           resultClass:resultClass
                                isList:NO];
}

+ commandWithSignal:(unsigned char)signalChar
          parameter:(VTRecord *)parameter
       resultsClass:(Class)resultClass {
  return [[self alloc] initWithSignal:signalChar
                             parameter:parameter
                           resultClass:resultClass
                                isList:YES];
}

#pragma mark - Init methods.

- (instancetype)initWithSignal:(unsigned char)signalChar
                     parameter:(VTRecord *)parameter
                   resultClass:(Class)resultClass
                        isList:(BOOL)flag {
  if ((self = [super init])) {
    _signal = signalChar;
    _parameter = parameter;
    _resultClass = resultClass;
    _returnsList = flag;
  }
  return self;
}


#pragma mark - Public methods

- (BOOL)flowControl {
  return NO;
}

@end
