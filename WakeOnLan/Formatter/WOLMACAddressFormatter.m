//
//  WOLMACAddressFormatter.m
//  WakeOnLan
//
//  Created by Clément Padovani on 7/31/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "WOLMACAddressFormatter.h"
@import AppKit;

const NSUInteger kWOLMACAddressFormatterMACAddressLength = 17;

@interface WOLMACAddressFormatter ()

@property (copy) NSCharacterSet *forbiddenMACAddressCharacterSet;

@end


@implementation WOLMACAddressFormatter

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		NSCharacterSet *forbiddenMACAddressCharacterSet = [[NSCharacterSet characterSetWithCharactersInString: @"0123456789:abcdefABCDEF"] invertedSet];
		
		_forbiddenMACAddressCharacterSet = [forbiddenMACAddressCharacterSet copy];
	}
	
	return self;
}

- (BOOL) isPartialStringValid:(NSString *__autoreleasing  _Nonnull *)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString *__autoreleasing  _Nullable *)error
{
//	CPLog(@"proposed: %@", NSStringFromRange(*proposedSelRangePtr));
	
	NSRange foundRange;
	NSCharacterSet *disallowedCharacters = [self forbiddenMACAddressCharacterSet];
	
	foundRange = [*partialStringPtr rangeOfCharacterFromSet:disallowedCharacters];
	if(foundRange.location != NSNotFound) {
		*error = @"MAC Adress contains invalid characters";
		NSBeep();
		return NO;
	}
	
	//00:D0:4B:8D:A3:38
	
	if([*partialStringPtr length] > kWOLMACAddressFormatterMACAddressLength) {
		*error = @"MAC Adress is too long.";
//		*partialStringPtr = origString;
		NSBeep();
		return NO;
	}
	
	if ([origString length] > [*partialStringPtr length])
	{
//		CPLog(@"proposed range: %@", NSStringFromRange(*proposedSelRangePtr));
//		
//		CPLog(@"selected string: %@", [*partialStringPtr substringWithRange: *proposedSelRangePtr]);
//		
//		CPLog(@"selected string: %@", [origString substringWithRange: *proposedSelRangePtr]);
//		
//		CPLog(@"string: %@", [origString substringWithRange: origSelRange]);
		
		NSString *deletedString = [origString substringWithRange: origSelRange];
		
		NSString *remainingString = [origString substringFromIndex: origSelRange.location + origSelRange.length];
		
		NSString *beginningString = [origString substringToIndex: origSelRange.location];
		
		if (remainingString &&
		    [remainingString length])
		{
//			CPLog(@"has string");
			
			*partialStringPtr = beginningString;
			
			proposedSelRangePtr->location = [beginningString length];
			
			return NO;
		}
		
		if ([deletedString isEqualToString: @":"])
		{
			NSString *updatedString = [origString substringToIndex: origSelRange.location - 1];
			
//			CPLog(@"updated: %@", updatedString);
			
			*partialStringPtr = updatedString;
			
			proposedSelRangePtr->location = [updatedString length];
			
			return NO;
		}
		
		return YES;
	}
	
	NSString *tempPartialString = [*partialStringPtr copy];
	
	if ([tempPartialString length] % 2 != 0)
	{
		NSArray *addressParts = [tempPartialString componentsSeparatedByString: @":"];
		
		if ([addressParts count] == 1)
		{
			if ([tempPartialString length] > 2)
			{
				NSMutableString *newPartialString = [NSMutableString string];
				
				__block NSUInteger currentIndex = 0;
				
				[tempPartialString enumerateSubstringsInRange: NSMakeRange(0, [tempPartialString length])
											   options: NSStringEnumerationByComposedCharacterSequences
											usingBlock: ^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
												
//												CPLog(@"char: %@", substring);
												
												if (currentIndex != 0 &&
												    currentIndex % 2 == 0)
													[newPartialString appendString: @":"];
												
												[newPartialString appendString: [substring uppercaseString]];
												
												
												
												currentIndex++;
												
											}];
				
				tempPartialString = [newPartialString copy];
				
				*partialStringPtr = [tempPartialString copy];
			}
		}
	}
	
	NSString *strippedString = [*partialStringPtr stringByReplacingOccurrencesOfString: @":"
														   withString: @""];
	
	NSString *updatedString = [*partialStringPtr copy];
	
	NSString *lastCharacterString = [*partialStringPtr substringWithRange: NSMakeRange([*partialStringPtr length] - 1,  1)];
	
	BOOL isValid = YES;
	
	BOOL didAddCharacter = NO;
	
	if ((![lastCharacterString isEqualToString: @":"]) &&
	    ([strippedString length] % 2 == 0) &&
	    ([strippedString length] < 12))
	{
		updatedString = [updatedString stringByAppendingString: @":"];
		
		isValid = NO;
		
		didAddCharacter = YES;
	}
	
	if (!isValid &&
	    didAddCharacter)
	{
		proposedSelRangePtr->location += 1;
	}
	
	BOOL needsUppercase = NO;

	needsUppercase = ![lastCharacterString isEqualToString: [lastCharacterString uppercaseString]];
	
	if (needsUppercase)
	{
		isValid = NO;
		
		updatedString = [updatedString uppercaseString];
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
//	CPLog(@"partial: %@", partialString);
//	
//	CPLog(@"new: %@", *newString);
//	
//	NSString *strippedString = [partialString stringByReplacingOccurrencesOfString: @":"
//														   withString: @""];
//	
//	NSString *updatedString = [partialString copy];
//	
//	NSString *lastCharacterString = [partialString substringWithRange: NSMakeRange([partialString length] - 1,  1)];
//
//	CPLog(@"stripped: %lu", [strippedString length]);
//	
//	CPLog(@"last char: %@", lastCharacterString);
//	
//	BOOL isValid = YES;
//	
//	if ((![lastCharacterString isEqualToString: @":"]) &&
//	    ([strippedString length] % 2 == 0))
//	{
//		CPLog(@"do update");
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
//	CPLog(@"partial: %@", *partialStringPtr);
//
//	CPLog(@"ori: %@", origString);
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
//	CPLog(@"new");
//	
//	NSString *tempString = [*partialStringPtr copy];
//	
//	tempString = [tempString stringByReplacingOccurrencesOfString: @":" withString: @""];
//	
//	NSUInteger stringLength = [tempString length];
//	
//	CPLog(@"partial: %@", *partialStringPtr);
//	
//	CPLog(@"ori: %@", origString);
//	
//	if (stringLength % 2 == 0 &&
//	    ![[*partialStringPtr substringFromIndex: ([*partialStringPtr length] - 1)] isEqualToString: @":"])
//	{
//		CPLog(@"substring: %@", [*partialStringPtr substringToIndex: [*partialStringPtr length] - 1]);
//		
//		CPLog(@"other: %@", [*partialStringPtr substringFromIndex: [*partialStringPtr length] - 1]);
//		
//		CPLog(@"fail here");
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
//								   //								   CPLog(@"char: %@", substring);
//								   
//								   if ([substring rangeOfCharacterFromSet: [self macAddressCharacterSet] options: NSCaseInsensitiveSearch].location == NSNotFound)
//								   {
//									   CPLog(@"found bad chars: %@", substring);
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
//		//		CPLog(@"chars: %@", aComponent);
//		if (foundBadCharacters)
//		{
//			CPLog(@"found bad char");
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
	//	CPLog(@"object: %@", obj);
	
	return [obj description];
}


@end
