//
//  CustomSoundManagerTests.swift
//  RadialTimer
//

@testable import UserPreferences
import XCTest

final class CustomSoundManagerTests: XCTestCase {
  var soundManager: CustomSoundManager!
  var testSoundsDirectory: URL!

  override func setUp() {
    super.setUp()
    soundManager = CustomSoundManager.shared

    // Create a temporary test directory
    let tempDir = FileManager.default.temporaryDirectory
    testSoundsDirectory = tempDir.appendingPathComponent("TestCustomSounds-\(UUID().uuidString)")
    try? FileManager.default.createDirectory(at: testSoundsDirectory, withIntermediateDirectories: true)
  }

  override func tearDown() {
    // Clean up test directory
    try? FileManager.default.removeItem(at: testSoundsDirectory)

    // Clean up any custom sounds directory created during tests
    if let customSoundsDir = try? soundManager.getCustomSoundsDirectory() {
      try? FileManager.default.removeItem(at: customSoundsDir)
    }

    super.tearDown()
  }

  // MARK: - Directory Tests

  func testGetCustomSoundsDirectory() throws {
    let directory = try soundManager.getCustomSoundsDirectory()

    // Verify directory exists
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory)
    XCTAssertTrue(exists)
    XCTAssertTrue(isDirectory.boolValue)

    // Verify directory is in Application Support
    XCTAssertTrue(directory.path.contains("Application Support"))
  }

  // MARK: - Validation Tests

  func testValidateNonExistentFile() throws {
    let nonExistentURL = testSoundsDirectory.appendingPathComponent("nonexistent.mp3")

    XCTAssertThrowsError(try soundManager.validateAudioFile(at: nonExistentURL)) { error in
      XCTAssertEqual(error as? CustomSoundError, .fileNotFound)
    }
  }

  func testValidateInvalidFileFormat() throws {
    // Create a test file with invalid extension
    let invalidURL = testSoundsDirectory.appendingPathComponent("test.txt")
    try "test".write(to: invalidURL, atomically: true, encoding: .utf8)

    XCTAssertThrowsError(try soundManager.validateAudioFile(at: invalidURL)) { error in
      XCTAssertEqual(error as? CustomSoundError, .invalidFileFormat)
    }
  }

  func testValidateFileTooLarge() throws {
    // Create a test file larger than 5MB
    let largeFileURL = testSoundsDirectory.appendingPathComponent("large.mp3")
    let largeData = Data(count: 6 * 1024 * 1024) // 6MB
    try largeData.write(to: largeFileURL)

    XCTAssertThrowsError(try soundManager.validateAudioFile(at: largeFileURL)) { error in
      XCTAssertEqual(error as? CustomSoundError, .fileTooLarge)
    }
  }

  // MARK: - Custom Sound Exists Tests

  func testCustomSoundExistsWithNilURL() throws {
    XCTAssertFalse(soundManager.customSoundExists(at: nil))
  }

  func testCustomSoundExistsWithNonExistentURL() throws {
    let nonExistentURL = URL(fileURLWithPath: "/tmp/nonexistent_sound.mp3")
    XCTAssertFalse(soundManager.customSoundExists(at: nonExistentURL))
  }

  func testCustomSoundExistsWithValidURL() throws {
    // Create a test file
    let testURL = testSoundsDirectory.appendingPathComponent("test.mp3")
    try Data().write(to: testURL)

    XCTAssertTrue(soundManager.customSoundExists(at: testURL))
  }

  // MARK: - Remove Custom Sound Tests

  func testRemoveCustomSoundWhenNoneExists() throws {
    // Should not throw error when no custom sound exists
    XCTAssertNoThrow(try soundManager.removeCustomSound())
  }

  // Note: Full integration tests for importCustomSound would require creating
  // valid audio files, which is beyond the scope of unit tests. These should be
  // covered by UI/integration tests with actual audio files.
}
