public enum Icon {
  /// Display an icon at the passed location.
  case icon(location: String)
  /// Display an icon for the path.
  case fileIcon(forPath: String)
  /// Display an icon of a specific file.
  case fileType(of: String)
}

extension Icon: Codable {
  private enum CodingKeys: String, CodingKey {
    case type
    case path
  }

  /// The `type` value for the icons.
  private enum IconType: String {
    case fileIcon = "fileicon"
    case fileType = "filetype"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let path = try container.decode(String.self, forKey: .path)
    let type = try container.decodeIfPresent(String.self, forKey: .type)
    switch type {
    case nil:
      // .icon has no type.
      self = .icon(location: path)

    case IconType.fileIcon.rawValue:
      self = .fileIcon(forPath: path)

    case IconType.fileType.rawValue:
      self = .fileType(of: path)

    case .some(let type):
      throw DecodingError.dataCorruptedError(
        forKey: CodingKeys.type, in: container,
        debugDescription: "Unexpected value for key: \(type)")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .icon(location: let path):
      // No type for icon.
      try container.encode(path, forKey: .path)
    case .fileIcon(forPath: let path):
      try container.encode(IconType.fileIcon.rawValue, forKey: .type)
      try container.encode(path, forKey: .path)
    case .fileType(of: let path):
      try container.encode(IconType.fileType.rawValue, forKey: .type)
      try container.encode(path, forKey: .path)
    }
  }
}

extension Icon: Equatable {}
