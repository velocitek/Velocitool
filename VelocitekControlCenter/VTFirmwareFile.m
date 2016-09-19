#import "VTFirmwareFile.h"


@interface VTFirmwareFile (private)

- (id)initWithFilePath:(NSString *)filePath;
-(NSMutableArray *)createArrayOfStrings;
-(void)removeExtraneousLines:(NSMutableArray *)arrayOfStrings;
-(void)convertToArrayOfDataObjects:(NSMutableArray *)arrayOfStrings;
-(void)createFirmwareDataArray;

@end


//Private methods
@implementation VTFirmwareFile (private)


//This routine takes a string containing the contents of a firmware file and creates an array of NSData objects.  Each element in the array corresponds to a line of firmware code.  The bytes in the data object correspond the the ASCII values of the characters in the string.
-(void)createFirmwareDataArray
{
	
	NSMutableArray *arrayOfStrings = [self createArrayOfStrings];
	
	[self removeExtraneousLines:arrayOfStrings];
	
	/*
	for (NSString *string in arrayOfStrings)
	{
		NSLog(@"%@",string);
		
	}
	*/
	
	
	[self convertToArrayOfDataObjects:arrayOfStrings];
	
}

//Takes a string containing the contents of a firmware file and converts it to an array where each element is a line of the firmware file.
-(NSMutableArray *)createArrayOfStrings
{
	//use componentsSeparatedByString to create an array of lines
	return [[[rawFirmwareString componentsSeparatedByString:@"\n"] mutableCopy] autorelease];	
}


//Goes through an array of strings and removes all the elements that do not begin with the character ':' 
-(void)removeExtraneousLines:(NSMutableArray *)arrayOfStrings
{
	
	NSString *line;
	bool removeLine = NO;
	
	unsigned int i = 0;
	//For each element in arrayOfStrings
	for (i = 0; i < [arrayOfStrings count]; i++)
	{
		line = [arrayOfStrings objectAtIndex:i];
		
		//if the line is empty
		if ([line length] == 0)
		{						
				removeLine = YES;
		}
		//if the first character in the line is not ':'
		else if ([line characterAtIndex:0] != ':') 
		{
			
			removeLine = YES;						
			
		}
		
		if (removeLine)
		{
			[arrayOfStrings removeObjectAtIndex:i];
			
			//Decrement the loop counter to account for the fact that all the array elements have been shifted
			//backwards to fill the hole we just created by removing an element
			i--;
		
		}
		
									
	}
	
	
}




//This routines takes an array of NSString objects and converts it to an array of NSData objects.  The bytes in the data object correspond the the ASCII values of the characters in the string.
-(void)convertToArrayOfDataObjects:(NSMutableArray *)arrayOfStrings
{
#define MAX_FIRMWARE_LINE_LENGTH 100
	char cString[MAX_FIRMWARE_LINE_LENGTH];
	
	NSData *lineAsData;
	
	NSMutableArray *arrayOfDataLines = [[NSMutableArray alloc] init];
	
	
	
	//for each line in the array
	for (NSString *line in arrayOfStrings)
	{
		//use cStringUsingEncoding to convert the line to a C string
		[line getCString:cString maxLength:MAX_FIRMWARE_LINE_LENGTH encoding:NSASCIIStringEncoding];
		
		//use dataWithBytes to convert the Cstring to a data object
		lineAsData = [NSData dataWithBytes:cString length:[line length]];
		
		
		//add the data object to the firmwareDataArray
		[arrayOfDataLines addObject:lineAsData];
	}
	
	firmwareData = arrayOfDataLines;			
	
}

- (id)initWithFilePath:(NSString *)filePath
{
  if ((self = [super init])) {
    rawFirmwareString = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:NULL];
    
    [self createFirmwareDataArray];
  }
	return self;
	
}

@end


//Public methods
@implementation VTFirmwareFile

@synthesize firmwareData;

//This routine constructs a VTFirmwareFile object given a path to a firmware file
+ (id)vtFirmwareFileWithFilePath:(NSString *)filePath
{
	VTFirmwareFile *firmwareFile = [[self alloc] initWithFilePath:filePath];
	
	[firmwareFile autorelease];
	
	return firmwareFile;
	
}


@end




