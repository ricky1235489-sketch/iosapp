import SpriteKit

struct Zone: Equatable {
    let name: String
    let backgroundColor: SKColor
    let obstacleColor: SKColor
    let accentColor: SKColor
}

struct ZoneManager {
    private let zones: [Zone] = [
        Zone(
            name: "Neon Drift",
            backgroundColor: SKColor(red: 0.03, green: 0.05, blue: 0.10, alpha: 1),
            obstacleColor: SKColor(red: 1.00, green: 0.20, blue: 0.45, alpha: 1),
            accentColor: SKColor(red: 0.10, green: 0.85, blue: 1.00, alpha: 1)
        ),
        Zone(
            name: "Cyber Canyon",
            backgroundColor: SKColor(red: 0.05, green: 0.03, blue: 0.12, alpha: 1),
            obstacleColor: SKColor(red: 0.72, green: 0.35, blue: 1.00, alpha: 1),
            accentColor: SKColor(red: 1.00, green: 0.82, blue: 0.20, alpha: 1)
        ),
        Zone(
            name: "Asteroid Bloom",
            backgroundColor: SKColor(red: 0.02, green: 0.10, blue: 0.12, alpha: 1),
            obstacleColor: SKColor(red: 0.55, green: 1.00, blue: 0.35, alpha: 1),
            accentColor: SKColor(red: 1.00, green: 0.36, blue: 0.70, alpha: 1)
        ),
        Zone(
            name: "Aurora Gate",
            backgroundColor: SKColor(red: 0.04, green: 0.09, blue: 0.07, alpha: 1),
            obstacleColor: SKColor(red: 1.00, green: 0.62, blue: 0.20, alpha: 1),
            accentColor: SKColor(red: 0.45, green: 0.95, blue: 0.85, alpha: 1)
        )
    ]

    func zone(forScore score: Int) -> Zone {
        let index = (max(score, 0) / 1_500) % zones.count
        return zones[index]
    }
}
