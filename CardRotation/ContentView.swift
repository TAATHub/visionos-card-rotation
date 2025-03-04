import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        VStack(spacing: 64) {
            Text("Card Rotation")
                .font(.system(size: 64, weight: .bold))

            ToggleImmersiveSpaceButton()
        }
        .padding()
        .frame(width: 600, height: 400)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
