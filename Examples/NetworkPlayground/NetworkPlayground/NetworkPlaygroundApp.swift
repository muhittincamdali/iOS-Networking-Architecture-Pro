import SwiftUI

@main
struct NetworkPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            PlaygroundView(initialScreen: Self.launchScreen)
        }
    }

    /// The screen named after `-screen` on the command line, such as `-screen retries`.
    /// scripts/capture-example-screens.sh uses it to open each screen and run its demo.
    private static var launchScreen: PlaygroundView.Screen? {
        UserDefaults.standard.string(forKey: "screen").flatMap(PlaygroundView.Screen.init(rawValue:))
    }
}
