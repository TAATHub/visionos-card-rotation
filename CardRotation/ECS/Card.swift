import RealityKit

enum CardFlipState {
    case front, back
    
    mutating func toggle() {
        switch self {
        case .front:
            self = .back
        case .back:
            self = .front
        }
    }
}

struct CardFlipComponent: Component {
    var state: CardFlipState = .front
    /// Target angle after flipped
    var targetAngle: Float?
}

final class CardFlipSystem: System {
    let query = EntityQuery(where: .has(CardFlipComponent.self))
    let speed: Float = 5.0

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        let entities = context.entities(matching: query, updatingSystemWhen: .rendering)
        
        for entity in entities {
            guard var component = entity.components[CardFlipComponent.self],
                  let targetAngle = component.targetAngle else { continue }
            
            // entity.orientation.axis.y cound be minus, so we need to convert the angle to plus in that case
            let angle = entity.orientation.axis.y < 0 ? 2 * .pi - entity.orientation.angle : entity.orientation.angle
            
            // orientation direction
            let direction: Float = component.state == .front ? -1 : 1
            
            print("targetAngle: \(targetAngle * 180 / .pi), angle: \(angle * 180 / .pi)")
            
            if abs(angle - targetAngle) > .pi / 180 {
                // If the diff of current angle and target angle is within 1 degree, then set orientation with additional angle
                let orientation = simd_quatf(angle: direction * Float(context.deltaTime) * speed, axis: .init(0, 1, 0))
                // Apply additional orientation to the entity with relative to itself
                entity.setOrientation(orientation, relativeTo: entity)
            } else {
                // Set orientation with target angle
                let orientation = simd_quatf(angle: targetAngle, axis: .init(0, 1, 0))
                // Apply global orientation to the entity
                entity.setOrientation(orientation, relativeTo: nil)
                
                component.targetAngle = nil
                entity.components.set(component)
            }
        }
    }
}
