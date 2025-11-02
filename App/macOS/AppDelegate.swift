import Cocoa
import SwiftUI
import TimerFeature

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusBar: NSStatusBar!
    var statusBarMenu: NSMenu!
    var statusItem: NSStatusItem!
    var isMuted: Bool = false

    let viewModel = TimerViewModel()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = NSHostingView(rootView: TimerFeature.MenuView(
            viewModel: viewModel,
            onClose: { [weak self] in
                guard let self = self else { return }
                self.statusItem.button?.performClick(nil)
            })
        )
        contentView.frame = NSRect(x: 0, y: 0, width: 150, height: 120)

        // Status bar icon SwiftUI view & a hosting view.
        //
        let iconSwiftUI = ZStack {
            CircularAnalogView(viewModel: self.viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.horizontal, 4)
        }

        let iconView = NSHostingView(rootView: iconSwiftUI)
        iconView.frame = NSRect(x: 0, y: 0, width: 26, height: 22)

        // Creating a menu item & the menu to add them later into the status bar
        //
        let menuItem = NSMenuItem()
        menuItem.view = contentView
        statusBarMenu = NSMenu()
        statusBarMenu.delegate = self
        statusBarMenu.addItem(menuItem)

        // Adding content view to the status bar
        //
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.action = #selector(statusBarButtonClicked(sender:))
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
//        statusItem.menu = menu

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
            viewModel.toggleTimer()
        } else {
            statusItem.menu = statusBarMenu
            statusItem.button?.performClick(nil)
        }
    }

    @objc func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil // remove menu so button works as before
    }
}
