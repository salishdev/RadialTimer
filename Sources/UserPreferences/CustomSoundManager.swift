import AppKit
import Foundation

/// Error types for custom sound operations
public enum CustomSoundError: LocalizedError {
  case invalidFileFormat
  case fileTooLarge
  case fileNotFound
  case copyFailed
  case invalidAudioFile

  public var errorDescription: String? {
    switch self {
    case .invalidFileFormat:
      return "Unsupported audio format. Please use MP3, WAV, M4A, or AIFF files."
    case .fileTooLarge:
      return "Audio file is too large. Maximum file size is 5MB."
    case .fileNotFound:
      return "Audio file not found."
    case .copyFailed:
      return "Failed to copy audio file to app container."
    case .invalidAudioFile:
      return "Unable to load audio file. Please ensure it's a valid audio file."
    }
  }
}

/// Manages custom sound file operations including validation, storage, and cleanup
public final class CustomSoundManager {
  /// Shared instance for convenience
  public static let shared = CustomSoundManager()

  /// Supported audio file extensions
  private let supportedFormats: Set<String> = ["mp3", "wav", "m4a", "aiff", "caf"]

  /// Maximum file size in bytes (5MB)
  private let maxFileSize: Int64 = 5 * 1024 * 1024

  /// Directory name for custom sounds in app support
  private let customSoundsDirectory = "CustomSounds"

  private init() {}

  /// Returns the directory URL for storing custom sounds
  /// - Throws: Error if directory cannot be created
  public func getCustomSoundsDirectory() throws -> URL {
    let fileManager = FileManager.default
    let appSupportURL = try fileManager.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )

    let customSoundsURL = appSupportURL.appendingPathComponent(customSoundsDirectory)

    // Create directory if it doesn't exist
    if !fileManager.fileExists(atPath: customSoundsURL.path) {
      try fileManager.createDirectory(at: customSoundsURL, withIntermediateDirectories: true)
    }

    return customSoundsURL
  }

  /// Validates an audio file URL
  /// - Parameter url: The URL of the audio file to validate
  /// - Throws: CustomSoundError if validation fails
  public func validateAudioFile(at url: URL) throws {
    // Start accessing security-scoped resource for sandboxed file access
    let shouldStopAccessing = url.startAccessingSecurityScopedResource()
    defer {
      if shouldStopAccessing {
        url.stopAccessingSecurityScopedResource()
      }
    }

    let fileManager = FileManager.default

    // Check if file exists
    guard fileManager.fileExists(atPath: url.path) else {
      throw CustomSoundError.fileNotFound
    }

    // Check file format
    let fileExtension = url.pathExtension.lowercased()
    guard supportedFormats.contains(fileExtension) else {
      throw CustomSoundError.invalidFileFormat
    }

    // Check file size
    let attributes = try fileManager.attributesOfItem(atPath: url.path)
    let fileSize = attributes[.size] as? Int64 ?? 0
    guard fileSize <= maxFileSize else {
      throw CustomSoundError.fileTooLarge
    }

    // Verify the file can be loaded as an NSSound
    guard NSSound(contentsOf: url, byReference: false) != nil else {
      throw CustomSoundError.invalidAudioFile
    }
  }

  /// Imports a custom sound file by copying it to the app container
  /// - Parameter sourceURL: The URL of the audio file to import
  /// - Returns: The URL of the copied file in the app container
  /// - Throws: CustomSoundError if validation or copying fails
  public func importCustomSound(from sourceURL: URL) throws -> URL {
    // Start accessing security-scoped resource for sandboxed file access
    let shouldStopAccessing = sourceURL.startAccessingSecurityScopedResource()
    defer {
      if shouldStopAccessing {
        sourceURL.stopAccessingSecurityScopedResource()
      }
    }

    // Validate the source file
    try validateAudioFile(at: sourceURL)

    let fileManager = FileManager.default
    let customSoundsDir = try getCustomSoundsDirectory()

    // Remove any existing custom sound first
    try removeCustomSound()

    // Create destination URL preserving the original filename
    let originalFilename = sourceURL.lastPathComponent
    let destinationURL = customSoundsDir.appendingPathComponent(originalFilename)

    // Copy file to app container
    do {
      try fileManager.copyItem(at: sourceURL, to: destinationURL)
      return destinationURL
    } catch {
      throw CustomSoundError.copyFailed
    }
  }

  /// Removes the custom sound file from app container
  /// - Throws: Error if file removal fails (silent if file doesn't exist)
  public func removeCustomSound() throws {
    let fileManager = FileManager.default
    let customSoundsDir = try getCustomSoundsDirectory()

    // Remove all files in the custom sounds directory (we only allow one custom sound)
    let contents = try? fileManager.contentsOfDirectory(
      at: customSoundsDir,
      includingPropertiesForKeys: nil
    )

    if let contents = contents {
      for fileURL in contents {
        try fileManager.removeItem(at: fileURL)
      }
    }
  }

  /// Checks if a custom sound file exists at the given URL
  /// - Parameter url: The URL to check
  /// - Returns: true if the file exists and is accessible, false otherwise
  public func customSoundExists(at url: URL?) -> Bool {
    guard let url = url else { return false }
    return FileManager.default.fileExists(atPath: url.path)
  }
}
