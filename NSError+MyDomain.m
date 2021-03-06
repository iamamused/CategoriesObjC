#import "NSError+MyDomain.h"
#import "NSError+InfoAccess.h"
#import "NSBundle+MainApp.h"

@implementation NSError (MyDomain)

+ (NSError*)errorWithLocalizedDescription:(NSString*)localizedDescription
									 code:(NSInteger)code
						   prettyFunction:(const char*)prettyFunction {
	NSDictionary* userInfo = nil ;
	if (localizedDescription) {
		NSString* const CFBundleVersionKey = @"CFBundleVersion" ;
		userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					localizedDescription, NSLocalizedDescriptionKey,
					[[NSBundle mainAppBundle] objectForInfoDictionaryKey:CFBundleVersionKey], CFBundleVersionKey,
					// The following gets added in -[SSYAlert support:].  It would be nice to do it here instead.
					// But then I'd have to #import SSYSystemDescriber into any project using this file.
					//[SSYSystemDescriber softwareVersionAndArchitecture], @"System Description",
					nil] ;
	}
    
	NSError* error = [NSError errorWithDomain:[self myDomain]
										 code:code
									 userInfo:userInfo] ;
    
	error = [error errorByAddingPrettyFunction:prettyFunction] ;
	error = [error errorByAddingTimestampNow] ;
	
	return error ;
}

+ (NSString*)myDomain {
	NSString* domain = [[NSBundle mainAppBundle] bundleIdentifier] ;
	// Background/daemon/helper/tools will usually not have a bundle...
	if (!domain) {
		NSString* path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0] ;
		domain = [path lastPathComponent] ;
	}
	if (!domain) {
		domain = @"UnknownErrorDomain" ;
	}
	
	return domain ;
}

@end
