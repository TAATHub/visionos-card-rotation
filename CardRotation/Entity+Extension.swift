import UIKit
import RealityKit

extension Entity {
    static func createCard(number: Int) -> Entity {
        let card = Entity()
        card.name = "card\(number)"
        card.components.set(InputTargetComponent())
        card.components.set(CollisionComponent(shapes: [.generateBox(size: .init(0.3, 0.4, 0.01))]))
        
        let front = ModelEntity(mesh: .generateBox(size: .init(0.3, 0.4, 0.001), cornerRadius: 0.01), materials: [UnlitMaterial(color: .white)])
        front.position = [0, 0, 0.0005]
        
        let back = ModelEntity(mesh: .generateBox(size: .init(0.3, 0.4, 0.001), cornerRadius: 0.01), materials: [UnlitMaterial(color: .black)])
        back.position = [0, 0, -0.0005]
        back.orientation = .init(angle: .pi, axis: .init(0, 1, 0))
        
        let frontText = createCardText(number: number, color: .black)
        frontText.position = [0, 0, 0.001]
        front.addChild(frontText)
        
        let backText = createCardText(number: number, color: .white)
        backText.position = [0, 0, 0.001]
        back.addChild(backText)
        
        card.addChild(front)
        card.addChild(back)
        
        card.components.set(CardFlipComponent())
        return card
    }
    
    static func createCardText(number: Int, color: UIColor) -> Entity {
        let text = Entity()
        let attributedString = AttributedString("CARD\(number)", attributes: .init([
            .font: UIFont.systemFont(ofSize: 128, weight: .bold),
            .foregroundColor: color
        ]))
        let attributedStringSize = NSAttributedString(attributedString).size()
        
        var textComponent = TextComponent()
        textComponent.text = attributedString
        textComponent.size = .init(width: attributedStringSize.width, height: attributedStringSize.height)
        text.components.set(textComponent)
        return text
    }
}
