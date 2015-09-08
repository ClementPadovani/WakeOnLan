//
//  WOLMACAddressFormatter.m
//  WakeOnLan
//
//  Created by Clément Padovani on 7/31/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "WOLMACAddressFormatter.h"
@import AppKit;

static const NSUInteger kWOLMACAddressFormatterMACAddressLength = 17;

@interface WOLMACAddressFormatter ()

@property (copy) NSCharacterSet *macAddressCharacterSet;

@end


@implementation WOLMACAddressFormatter

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		NSCharacterSet *hexadecimalCharacterSet = [NSCharacterSet characterSetWithCharactersInString: @"0123456789ABCDEFabcdef"];
		
		NSCharacterSet *seperatorCharacterSet = [NSCharacterSet characterSetWithCharactersInString: @":"];
		
		NSMutableCharacterSet *macAddressCharacterSet = [[NSMutableCharacterSet alloc] init];
		
		[macAddressCharacterSet formUnionWithCharacterSet: hexadecimalCharacterSet];
		
		[macAddressCharacterSet formUnionWithCharacterSet: seperatorCharacterSet];
		
//		[self setMacAddressCharacterSet: macAddressCharacterSet];
		
		_macAddressCharacterSet = [macAddressCharacterSet copy];
	}
	
	return self;
}

- (BOOL) isPartialStringValid:(NSString *__autoreleasing  _Nonnull *)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString *__autoreleasing  _Nullable *)error
{
	NSRange foundRange;
	NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789:abcdefABCDEF"] invertedSet];
	foundRange = [*partialStringPtr rangeOfCharacterFromSet:disallowedCharacters];
	if(foundRange.location != NSNotFound) {
		*error = @"MAC Adress contains invalid characters";
		NSBeep();
		return NO;
	}
	
	//00:D0:4B:8D:A3:38
	
	if([*partialStringPtr length] > kWOLMACAddressFormatterMACAddressLength) {
		NSLog(@"too long");
		*error = @"MAC Adress is too long.";
//		*partialStringPtr = origString;
		NSBeep();
		return NO;
	}
	
	NSLog(@"partial: %@", *partialStringPtr);
	
	NSLog(@"old: %@", origString);
	
	if ([origString length] > [*partialStringPtr length])
		return YES;
	
	NSString *strippedString = [*partialStringPtr stringByReplacingOccurrencesOfString: @":"
														   withString: @""];
	
	NSString *updatedString = [*partialStringPtr copy];
	
	NSString *lastCharacterString = [*partialStringPtr substringWithRange: NSMakeRange([*partialStringPtr length] - 1,  1)];
	
	NSLog(@"stripped: %lu", [strippedString length]);
	
	NSLog(@"last char: %@", lastCharacterString);
	
	BOOL isValid = YES;
	
	BOOL didAddCharacter = NO;
	
	if ((![lastCharacterString isEqualToString: @":"]) &&
	    ([strippedString length] % 2 == 0) &&
	    ([strippedString length] < 12))
	{
		NSLog(@"do update");
		
		updatedString = [updatedString stringByAppendingString: @":"];
		
		isValid = NO;
		
		didAddCharacter = YES;
	}
	
	if (!isValid &&
	    didAddCharacter)
	{
		proposedSelRangePtr->location += 1;
	}
	
	*partialStringPtr = updatedString;
	
	return isValid;
}

//- (BOOL) isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error {
//	
//	NSRange foundRange;
//	NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789:abcdefABCDEF"] invertedSet];
//	foundRange = [partialString rangeOfCharacterFromSet:disallowedCharacters];
//	if(foundRange.location != NSNotFound) {
//		*error = @"MAC Adress contains invalid characters";
//		NSBeep();
//		return NO;
//	}
//	
//	if([partialString length] > kWOLMACAddressFormatterMACAddressLength) {
//		*error = @"MAC Adress is too long.";
//		NSBeep();
//		return(NO);
//	}
//	
//	NSLog(@"partial: %@", partialString);
//	
//	NSLog(@"new: %@", *newString);
//	
//	NSString *strippedString = [partialString stringByReplacingOccurrencesOfString: @":"
//														   withString: @""];
//	
//	NSString *updatedString = [partialString copy];
//	
//	NSString *lastCharacterString = [partialString substringWithRange: NSMakeRange([partialString length] - 1,  1)];
//
//	NSLog(@"stripped: %lu", [strippedString length]);
//	
//	NSLog(@"last char: %@", lastCharacterString);
//	
//	BOOL isValid = YES;
//	
//	if ((![lastCharacterString isEqualToString: @":"]) &&
//	    ([strippedString length] % 2 == 0))
//	{
//		NSLog(@"do update");
//		
//		updatedString = [updatedString stringByAppendingString: @":"];
//		
//		isValid = NO;
//	}
//	
//	*newString = updatedString;
//	
//	return isValid;
//}

//- (BOOL) isPartialStringValid: (NSString *__autoreleasing  _Nonnull * _Nonnull) partialStringPtr proposedSelectedRange: (nullable NSRangePointer) proposedSelRangePtr originalString: (nonnull NSString *) origString originalSelectedRange: (NSRange) origSelRange errorDescription: (NSString *__autoreleasing  _Nullable * _Nullable) error
//{
//	if ((!*partialStringPtr ||
//		![*partialStringPtr length]) &&
//	    (!origString ||
//		![origString length]))
//		return YES;
//	
//	NSLog(@"partial: %@", *partialStringPtr);
//
//	NSLog(@"ori: %@", origString);
//	
//	if ([*partialStringPtr length] >= kWOLMACAddressFormatterMACAddressLength)
//	{
//		*partialStringPtr = [origString copy];
//		return NO;
//	}
//	
//	if (([origString length] > [*partialStringPtr length]) &&
//	    ([[origString substringFromIndex: ([origString length] - 1)] isEqualToString: @":"]))
//	{
//		*partialStringPtr = [[*partialStringPtr stringByReplacingCharactersInRange: NSMakeRange([*partialStringPtr length] - 1, 1) withString: @""] copy];
//		
//		proposedSelRangePtr->location = [*partialStringPtr length];
//		
//		return NO;
//	}
//	
//	NSLog(@"new");
//	
//	NSString *tempString = [*partialStringPtr copy];
//	
//	tempString = [tempString stringByReplacingOccurrencesOfString: @":" withString: @""];
//	
//	NSUInteger stringLength = [tempString length];
//	
//	NSLog(@"partial: %@", *partialStringPtr);
//	
//	NSLog(@"ori: %@", origString);
//	
//	if (stringLength % 2 == 0 &&
//	    ![[*partialStringPtr substringFromIndex: ([*partialStringPtr length] - 1)] isEqualToString: @":"])
//	{
//		NSLog(@"substring: %@", [*partialStringPtr substringToIndex: [*partialStringPtr length] - 1]);
//		
//		NSLog(@"other: %@", [*partialStringPtr substringFromIndex: [*partialStringPtr length] - 1]);
//		
//		NSLog(@"fail here");
//		
//		*partialStringPtr = [*partialStringPtr stringByAppendingString: @":"];
//		
//		proposedSelRangePtr->location = [*partialStringPtr length];
//		
//		return NO;
//	}
//	
//	NSArray *macAddressComponents = [*partialStringPtr componentsSeparatedByString: @":"];
//	
//	for (NSString *aComponent in macAddressComponents)
//	{
//		__block BOOL foundBadCharacters = NO;
//		
//		__block BOOL isMissingCharacters = NO;
//		
//		[aComponent enumerateSubstringsInRange: NSMakeRange(0, [aComponent length])
//								 options: NSStringEnumerationByComposedCharacterSequences
//							   usingBlock: ^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
//								   
//								   //								   NSLog(@"char: %@", substring);
//								   
//								   if ([substring rangeOfCharacterFromSet: [self macAddressCharacterSet] options: NSCaseInsensitiveSearch].location == NSNotFound)
//								   {
//									   NSLog(@"found bad chars: %@", substring);
//									   
//									   foundBadCharacters = YES;
//									   *stop = YES;
//								   }
//								   else if ([aComponent length] == 1)
//								   {
//									   isMissingCharacters = YES;
//									   *stop = YES;
//								   }
//							   }];
//		
//		//		NSLog(@"chars: %@", aComponent);
//		if (foundBadCharacters)
//		{
//			NSLog(@"found bad char");
//			
//			*partialStringPtr = [origString copy];
//			
//			proposedSelRangePtr->location = ([origString length] - 1);
//			
//			proposedSelRangePtr->length = 0;
//			
//			return NO;
//		}
//		else if (isMissingCharacters)
//		{
//			return YES;
//		}
//	}
//	
//	*partialStringPtr = [origString copy];
//	
//	return NO;
//}

- (BOOL) getObjectValue:(out id  _Nullable __autoreleasing * _Nullable)obj
		    forString:(nonnull NSString *)string
	  errorDescription:(out NSString *__autoreleasing  _Nullable * _Nullable)error
{
//	if (error)
//		*error = @"Not implemented";
	
	return NO;
}

- (NSString *) stringForObjectValue: (nonnull id) obj
{
	//	NSLog(@"object: %@", obj);
	
	return [obj description];
}


@end
