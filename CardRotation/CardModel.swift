import RealityKit
import Observation

@Observable
@MainActor
final class CardModel {
    private var cards: [Entity] = []
    
    /// Global rotation of cards (for cards position and orientation)
    private var cardsRotation: Float = .pi/2
    
    /// Global rotation of target card (for drag gesture)
    private var targetCardRotation: Float?
    
    func createCards() -> [Entity] {
        var cards: [Entity] = []
        
        // Place cards in circle
        for index in 0..<12 {
            let card = Entity.createCard(number: index + 1)
            placeCard(card, index: index)
            cards.append(card)
        }
        
        self.cards = cards
        return cards
    }
    
    func onDragChanged(translation: SIMD3<Float>) {
        if targetCardRotation == nil {
            targetCardRotation = cardsRotation
        }
        
        guard let targetCardRotation else { return }
        // Update cards rotation with translation by drag gesture
        cardsRotation = targetCardRotation - translation.x
        
        print("translation.x: \(translation.x), cardsRotation: \(cardsRotation)")
        
        for (index, card) in cards.enumerated() {
            // Update cards position and orientation
            placeCard(card, index: index)
        }
    }
    
    func onDragEnded() {
        targetCardRotation = nil
    }
    
    func onTapEnded(entity: Entity) {
        print("Tapped \(entity.name)")
        
        guard var component = entity.components[CardFlipComponent.self] else { return }
        component.state.toggle()
        
        let index = Int(entity.name.dropFirst(4))! - 1
        let rotation = cardRotation(index: index)
        var targetAngle = cardOrientationAngle(index: index, globalRotation: rotation, state: component.state)
        
        targetAngle = normalizeAngle(targetAngle)
        
        component.targetAngle = targetAngle
        entity.components.set(component)
    }
    
    private func placeCard(_ card: Entity, index: Int) {
        let rotation = cardRotation(index: index)
        card.position = [cos(rotation), 1.2, sin(rotation) - 2]
        
        if let state = card.components[CardFlipComponent.self]?.state {
            let angle = cardOrientationAngle(index: index, globalRotation: rotation, state: state)
            card.orientation = .init(angle: angle, axis: .init(0, 1, 0))
        }
    }
    
    /// Calculate rotation of target card from global cards rotation
    /// - Parameter index: target card index
    /// - Returns: rotation
    private func cardRotation(index: Int) -> Float {
        -.pi / 6 * Float(index) + cardsRotation
    }
    
    /// Calculate angle for orientation of target card from global card rotation
    /// - Parameters:
    ///   - index: target card index
    ///   - globalRotation: target card rotation
    ///   - state: card flip state
    /// - Returns: angle
    private func cardOrientationAngle(index: Int, globalRotation: Float, state: CardFlipState) -> Float {
        return state == .front ? .pi / 2 - globalRotation : .pi * 3 / 2 - globalRotation
    }
    
    /// Normalize angle to 0~2pi
    /// - Parameter angle: angle (radian)
    /// - Returns: normalized angle
    private func normalizeAngle(_ angle: Float) -> Float {
        let result = angle.truncatingRemainder(dividingBy: 2 * .pi)
        return result >= 0 ? result : result + 2 * .pi
    }
}
