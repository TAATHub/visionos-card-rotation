import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var cardModel: CardModel = .init()
    
    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(scene)

                _ = cardModel.createCards().map { scene.addChild($0) }

                CardFlipSystem.registerSystem()
            }
        }
        .gesture(DragGesture().targetedToAnyEntity().onChanged({ value in
            // Translation vector by drag gesture
            let translation = value.convert(value.gestureValue.translation3D, from: .local, to: .scene)
            cardModel.onDragChanged(translation: translation)
        }).onEnded({ _ in
            cardModel.onDragEnded()
        }))
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded({ value in
            cardModel.onTapEnded(entity: value.entity)
        }))
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
