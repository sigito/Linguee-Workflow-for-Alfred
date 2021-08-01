import Foundation

extension URLResponse {

  /// Returns an encoding based on the `Content-Type` header in the response.
  /// Returns `nil` if failed.
  var textEncoding: String.Encoding? {
    guard let IANAEncodingName = self.textEncodingName else {
      return nil
    }
    let cfStringEncoding = CFStringConvertIANACharSetNameToEncoding(IANAEncodingName as CFString)
    guard cfStringEncoding != kCFStringEncodingInvalidId else {
      return nil
    }
    let encodingRawValue = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding)
    return String.Encoding(rawValue: encodingRawValue)
  }
}
