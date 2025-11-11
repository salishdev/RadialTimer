import Cocoa
import SettingsFeature
import SwiftUI
import TimerFeature
import UserPreferences

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate {
  private var statusBar: NSStatusBar!
  private var statusBarMenu: NSMenu!
  private var contextMenu: NSMenu!
  private var statusItem: NSStatusItem!
  private var isMuted: Bool = false
  private var settingsWindowController: NSWindowController?

  let userPreferences = UserPreferences.shared
  let viewModel: TimerViewModel

  override init() {
    // Initialize view model with user preferences
    self.viewModel = TimerViewModel(userPreferences: userPreferences)
    super.init()
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let contentView = NSHostingView(rootView:
      TimerFeature.MenuView(
        viewModel: viewModel,
        onClose: { [weak self] in
          guard let self = self else { return }
          self.statusItem.button?.performClick(nil)
        },
        openSettings: openSettings
      )
      .userPreferences(userPreferences)
    )
    contentView.frame = NSRect(x: 0, y: 0, width: 150, height: 120)

    // Status bar icon SwiftUI view & a hosting view.
    //
    let iconSwiftUI = ZStack {
      MenuBarItemView(viewModel: self.viewModel)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.horizontal, 4)
    }
    .userPreferences(userPreferences)

    let iconView = NSHostingView(rootView: iconSwiftUI)
    iconView.frame = NSRect(x: 0, y: 0, width: 26, height: 22)

    // Creating a menu item & the menu to add them later into the status bar
    //
    let menuItem = NSMenuItem()
    menuItem.view = contentView
    statusBarMenu = NSMenu()
    statusBarMenu.delegate = self
    statusBarMenu.addItem(menuItem)

    // Creating context menu for right-click
    //
    contextMenu = NSMenu()
    contextMenu.delegate = self

    let toggleMenuItem = NSMenuItem(
      title: viewModel.isTimerOn ? "Pause Timer" : "Start Timer",
      action: #selector(toggleTimerFromMenu),
      keyEquivalent: ""
    )
    toggleMenuItem.target = self
    contextMenu.addItem(toggleMenuItem)

    let resetMenuItem = NSMenuItem(
      title: "Reset Timer",
      action: #selector(resetTimerFromMenu),
      keyEquivalent: ""
    )
    resetMenuItem.target = self
    contextMenu.addItem(resetMenuItem)

    contextMenu.addItem(NSMenuItem.separator())

    let settingsMenuItem = NSMenuItem(
      title: "Settings...",
      action: #selector(openSettingsFromMenu),
      keyEquivalent: ""
    )
    settingsMenuItem.target = self
    contextMenu.addItem(settingsMenuItem)

    contextMenu.addItem(NSMenuItem.separator())

    let quitMenuItem = NSMenuItem(
      title: "Quit",
      action: #selector(NSApplication.terminate(_:)),
      keyEquivalent: ""
    )
    contextMenu.addItem(quitMenuItem)

    // Adding content view to the status bar
    //
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem.button?.action = #selector(statusBarButtonClicked(sender:))
    statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

    // Adding the status bar icon
    //
    statusItem.button?.addSubview(iconView)
    statusItem.button?.frame = iconView.frame

    // StatusItem is stored as a property.
    self.statusItem = statusItem
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
    let event = NSApp.currentEvent!

    if event.type == NSEvent.EventType.rightMouseUp {
      // Right-click: Show context menu
      updateContextMenuItems()
      statusItem.menu = contextMenu
      statusItem.button?.performClick(nil)
    } else if event.modifierFlags.contains(.option) {
      // Option+Left-click: Toggle timer directly
      viewModel.toggleTimer()
    } else {
      // Left-click: Show popup menu
      statusItem.menu = statusBarMenu
      statusItem.button?.performClick(nil)
    }
  }

  @objc func menuDidClose(_ menu: NSMenu) {
    statusItem.menu = nil // remove menu so button works as before
  }

  func updateContextMenuItems() {
    // Update toggle menu item title based on timer state
    if let toggleItem = contextMenu.items.first {
      toggleItem.title = viewModel.isTimerOn ? "Stop Timer" : "Start Timer"
    }
  }

  @objc func toggleTimerFromMenu() {
    viewModel.toggleTimer()
  }

  @objc func resetTimerFromMenu() {
    viewModel.resetTimer()
  }

  @objc func openSettingsFromMenu() {
    openSettings()
  }

  func openSettings() {
    // If a settings window already exists, bring it to front
    if let controller = settingsWindowController, let window = controller.window {
      window.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
      return
    }

    // Build the SwiftUI settings view and host it in an NSWindow
    let settingsRoot = SettingsView()
      .userPreferences(userPreferences)

    let hostingController = NSHostingController(rootView: settingsRoot)

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 600, height: 420),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )
    window.title = "Settings"
    window.contentViewController = hostingController
    window.center()
    window.isReleasedWhenClosed = false
    window.delegate = self

    let controller = NSWindowController(window: window)
    settingsWindowController = controller

    controller.showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  func windowWillClose(_ notification: Notification) {
    if let window = notification.object as? NSWindow, window == settingsWindowController?.window {
      settingsWindowController = nil
    }
  }
}
