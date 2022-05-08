import Foundation

enum BlobKindKey: String, CodingKey {
    case type
    case blob
}

enum BlobKind: String, Codable {
    case png, heif, mov, mp4
}
