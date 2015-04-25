//
//  CHXErrorCodeDescription.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 2015-04-19.
//  Copyright (c) 2014 Moch Xiao (https://github.com/atcuan).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CHXErrorCodeDescription.h"

@implementation CHXErrorCodeDescription

NSString *CHXStringFromCFNetworkErrorCode(NSInteger code) {
    NSString *resultString = nil;
    switch (code) {
        case kCFHostErrorHostNotFound:
            resultString = @"Host Error: Host Not Found";
            break;
        case kCFHostErrorUnknown:
            resultString = @"Host Error: Unknown Host";
            break;
        case kCFSOCKSErrorUnknownClientVersion:
            resultString = @"SOCKS Error: Unknown Client Version";
            break;
        case kCFSOCKSErrorUnsupportedServerVersion:
            resultString = @"SOCKS Error: UnsupportedServerVersion";
            break;
        case kCFSOCKS4ErrorRequestFailed:
            resultString = @"SOCKS 4 Error: RequestFailed";
            break;
        case kCFSOCKS4ErrorIdentdFailed:
            resultString = @"SOCKS 4 Error: Identd Failed";
            break;
        case kCFSOCKS4ErrorIdConflict:
            resultString = @"SOCKS 4 Error: Id Conflict";
            break;
        case kCFSOCKS5ErrorBadState:
            resultString = @"SOCKS 5 Error: Bad State";
            break;
        case kCFSOCKS5ErrorBadResponseAddr:
            resultString = @"SOCKS 5 Error: Bad Response Addr";
            break;
        case kCFSOCKS5ErrorBadCredentials:
            resultString = @"SOCKS 5 Error: Bad Credentials";
            break;
        case kCFSOCKS5ErrorUnsupportedNegotiationMethod:
            resultString = @"SOCKS 5 Error: Unsupported Negotiation Method";
            break;
        case kCFSOCKS5ErrorNoAcceptableMethod:
            resultString = @"SOCKS 5 Error: No Acceptable Method";
            break;
        case kCFFTPErrorUnexpectedStatusCode:
            resultString = @"Ftp Error: Unexpected Status Code";
            break;
        case kCFErrorHTTPAuthenticationTypeUnsupported:
            resultString = @"HTTP Authentication Type Unsupported";
            break;
        case kCFErrorHTTPBadCredentials:
            resultString = @"HTTP Bad Credentials";
            break;
        case kCFErrorHTTPConnectionLost:
            resultString = @"HTTP Connection Lost";
            break;
        case kCFErrorHTTPParseFailure:
            resultString = @"HTTP Parse Failure";
            break;
        case kCFErrorHTTPRedirectionLoopDetected:
            resultString = @"HTTP Redirection Loop Detected";
            break;
        case kCFErrorHTTPBadURL:
            resultString = @"Error HTTP Bad URL";
            break;
        case kCFErrorHTTPProxyConnectionFailure:
            resultString = @"HTTP Proxy Connection Failure";
            break;
        case kCFErrorHTTPBadProxyCredentials:
            resultString = @"HTTP Bad Proxy Credentials";
            break;
        case kCFErrorPACFileError:
            resultString = @"PAC File Error";
            break;
        case kCFErrorPACFileAuth:
            resultString = @"PAC File Auth";
            break;
        case kCFErrorHTTPSProxyConnectionFailure:
            resultString = @"HTTPS Proxy Connection Failure";
            break;
        case kCFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod:
            resultString = @"HTTPS Proxy Failure, Unexpected Response To CONNECT Method";
            break;
        case kCFURLErrorBackgroundSessionInUseByAnotherProcess:
            resultString = @"URL Error: Background Session In Use By Another Process";
            break;
        case kCFURLErrorBackgroundSessionWasDisconnected:
            resultString = @"URL Error: Background Session Was Disconnected";
            break;
        case kCFURLErrorUnknown:
            resultString = @"URL Error: Unknown";
            break;
        case kCFURLErrorCancelled:
            resultString = @"URL Error: Cancelled";
            break;
        case kCFURLErrorBadURL:
            resultString = @"URL Error: Bad URL";
            break;
        case kCFURLErrorTimedOut:
            resultString = @"URL Error: Timed Out";
            break;
        case kCFURLErrorUnsupportedURL:
            resultString = @"URL Error: Unsupported URL";
            break;
        case kCFURLErrorCannotFindHost:
            resultString = @"URL Error: Cannot Find Host";
            break;
        case kCFURLErrorCannotConnectToHost:
            resultString = @"URL Error: Cannot Connect To Host";
            break;
        case kCFURLErrorNetworkConnectionLost:
            resultString = @"URL Error: Network Connection Lost";
            break;
        case kCFURLErrorDNSLookupFailed:
            resultString = @"URL Error: DNS Lookup Failed";
            break;
        case kCFURLErrorHTTPTooManyRedirects:
            resultString = @"URL Error: HTTP Too Many Redirects";
            break;
        case kCFURLErrorResourceUnavailable:
            resultString = @"URL Error: Resource Unavailable";
            break;
        case kCFURLErrorNotConnectedToInternet:
            resultString = @"URL Error: Not Connected To Internet";
            break;
        case kCFURLErrorRedirectToNonExistentLocation:
            resultString = @"URL Error: Redirect To Non Existent Location";
            break;
        case kCFURLErrorBadServerResponse:
            resultString = @"URL Error: Bad Server Response";
            break;
        case kCFURLErrorUserCancelledAuthentication:
            resultString = @"URL Error: User Cancelled Authentication";
            break;
        case kCFURLErrorUserAuthenticationRequired:
            resultString = @"URL Error: User Authentication Required";
            break;
        case kCFURLErrorZeroByteResource:
            resultString = @"URL Error: Zero Byte Resource";
            break;
        case kCFURLErrorCannotDecodeRawData:
            resultString = @"URL Error:  Cannot Decode RawData";
            break;
        case kCFURLErrorCannotDecodeContentData:
            resultString = @"URL Error: Cannot Decode Content Data";
            break;
        case kCFURLErrorCannotParseResponse:
            resultString = @"URL Error:  Cannot Parse Response";
            break;
        case kCFURLErrorInternationalRoamingOff:
            resultString = @"URL Error: International Roaming Off";
            break;
        case kCFURLErrorCallIsActive:
            resultString = @"URL Error: Call Is Active";
            break;
        case kCFURLErrorDataNotAllowed:
            resultString = @"URL Error: Data Not Allowed";
            break;
        case kCFURLErrorRequestBodyStreamExhausted:
            resultString = @"URL Error: Request Body Stream Exhausted";
            break;
        case kCFURLErrorFileDoesNotExist:
            resultString = @"URL Error: Error File Does Not Exist";
            break;
        case kCFURLErrorFileIsDirectory:
            resultString = @"URL Error: File Is Directory";
            break;
        case kCFURLErrorNoPermissionsToReadFile:
            resultString = @"URL Error: No Permissions To Read File";
            break;
        case kCFURLErrorDataLengthExceedsMaximum:
            resultString = @"URL Error: Data Length Exceeds Maximum";
            break;
        case kCFURLErrorSecureConnectionFailed:
            resultString = @"URL Error: Secure Connection Failed";
            break;
        case kCFURLErrorServerCertificateHasBadDate:
            resultString = @"URL Error: Server Certificate Has Bad Date";
            break;
        case kCFURLErrorServerCertificateUntrusted:
            resultString = @"URL Error: Server Certificate Untrusted";
            break;
        case kCFURLErrorServerCertificateHasUnknownRoot:
            resultString = @"URL Error: Server Certificate Has Unknown Root";
            break;
        case kCFURLErrorServerCertificateNotYetValid:
            resultString = @"URL Error: Server Certificate Not Yet Valid";
            break;
        case kCFURLErrorClientCertificateRejected:
            resultString = @"URL Error: Client Certificate Rejected";
            break;
        case kCFURLErrorClientCertificateRequired:
            resultString = @"URL Error: Client Certificate Required";
            break;
        case kCFURLErrorCannotLoadFromNetwork:
            resultString = @"URL Error: Cannot Load From Network";
            break;
        case kCFURLErrorCannotCreateFile:
            resultString = @"URL Error: Cannot Create File";
            break;
        case kCFURLErrorCannotOpenFile:
            resultString = @"URL Error: Cannot Open File";
            break;
        case kCFURLErrorCannotCloseFile:
            resultString = @"URL Error: Cannot Close File";
            break;
        case kCFURLErrorCannotWriteToFile:
            resultString = @"URL Error: Cannot Write To File";
            break;
        case kCFURLErrorCannotRemoveFile:
            resultString = @"URL Error: Cannot Remove File";
            break;
        case kCFURLErrorCannotMoveFile:
            resultString = @"URL Error: Cannot Move File";
            break;
        case kCFURLErrorDownloadDecodingFailedMidStream:
            resultString = @"URL Error: Download Decoding Failed Mid Stream";
            break;
        case kCFURLErrorDownloadDecodingFailedToComplete:
            resultString = @"URL Error: Download Decoding Failed To Complete";
            break;
        case kCFHTTPCookieCannotParseCookieFile:
            resultString = @"HTTP Cookie Cannot Parse Cookie File";
            break;
        case kCFNetServiceErrorUnknown:
            resultString = @"Service Error: Unknown";
            break;
        case kCFNetServiceErrorCollision:
            resultString = @"Service Error: Collision";
            break;
        case kCFNetServiceErrorNotFound:
            resultString = @"Service Error: Not Found";
            break;
        case kCFNetServiceErrorInProgress:
            resultString = @"Service Error: In Progress";
            break;
        case kCFNetServiceErrorBadArgument:
            resultString = @"Service Error:Bad Argument";
            break;
        case kCFNetServiceErrorCancel:
            resultString = @"Service Error: Cancel";
            break;
        case kCFNetServiceErrorInvalid:
            resultString = @"Service Error: Invalid";
            break;
        case kCFNetServiceErrorTimeout:
            resultString = @"kCFNetServiceErrorTimeout";
            break;
        case kCFNetServiceErrorDNSServiceFailure:
            resultString = @"Service Error: DNS Service Failure";
            break;
        default:
            resultString = @"Unrecognized Error";
            break;
    }
    
    return resultString;
}

@end
