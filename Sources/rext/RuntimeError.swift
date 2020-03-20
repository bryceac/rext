import Foundation

enum RuntimeError: Error, CustomStringConvertible {
    case missingExtensions, missingExtension, missingReplacement

    var description: String {
        switch self {
            case .missingExtensions: return "Please specify both extensions."
            case .missingExtension: return "Please specify extension to rename."
            case .missingReplacement: return "Please specify replacement extension."
        }
    }
}