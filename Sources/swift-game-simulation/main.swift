import Foundation

extension String {
    func times(_ numTimes: Int) -> String {
        return (1...numTimes).map({ String in self }).joined()
    }
}

extension Collection where Index == Int {
    /**
    Picks a random element of the collection.
    
    - returns: A random element of the collection.
    */
    func randomElement() -> Iterator.Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(endIndex)))]
    }
}

enum Item: String {
    case Potion
    case Staff
}

enum Mood {
    case Happy
    case Sad
    case Angry
}

extension Item {
    var info: String {
        switch self {
        case .Potion: return "Round"
        case .Staff: return "Staffy"
        }
    }
    
    // TODO: Chane this in Swift 4.2:
    // https://github.com/apple/swift-evolution/blob/master/proposals/0194-derived-collection-of-enum-cases.md
    static var allCases: [Item] = [
        .Potion, .Staff
    ]
    
    static func random() -> Item {
        return Item.allCases.randomElement()!
    }
}

enum LaughReason {
    case TargetIsWeak
}

class Player: CustomStringConvertible  {
    var name = "Lul" 
    var hp = 0 
    var mood = Mood.Happy 
    var inventory = [Item]()
    
    static func new(name: String, hp: Int) -> Player {
        let player = Player()
        player.name = name
        player.hp = hp
        player.inventory = []
        return player
    }
    
    func str() -> String {
        return "<Player \(self.name) with \(self.hp) hp>"
    }
    
    var description: String {
        return "<Player \(self.name) with \(self.hp) hp>"
    }
    
    func take(item: Item) {
        self.inventory.append(Item.random())
    }
    
    func take(compliment: String) {
        print("\(self.name) liked the compliment!")
    }
    
    func attack(_ other: Player) {
        let attackWeapon: Item? = 
            self.inventory.contains(.Staff)  ? .Staff :
            self.inventory.contains(.Potion) ? .Potion :
                                               nil
                                               
        let (damage, attackedWithString): (Int, String) = {
            switch attackWeapon {
                case .some(.Staff): return (5, "his staff")
                case .some(.Potion): return (4, "a potion")
                case nil: return (2, "his hands")
            }
        }()
                                               
        other.hp -= damage
        print("\(self.name) attacked \(other.name)",
              "with \(attackedWithString)",
              "for \(damage) damage")
        print("\(other.name) now has \(other.hp) hp left!")
    }
    
    func laugh(atPlayer other: Player, reason: LaughReason) {
        print("\(self.name) laughed at \(other.name)", terminator: ", ")
        
        switch reason {
        case .TargetIsWeak:
            print("because \(other.name) is so weak...")
            other.getLaughedAt(reason: reason)
        }
    }
    
    func getLaughedAt(reason: LaughReason) {
        switch reason {
        case .TargetIsWeak:
            self.setMood(.Sad)
        }
    }
    
    func setMood(_ newMood: Mood) {
        self.mood = newMood
        switch newMood {
        case .Happy:
            print("\(name) is happy now!")
        case .Sad:
            print("\(name) is sad now... :(")
        case .Angry:
            print("\(name) is ANGRY now!")
        }
    }
    
}

func setup() -> [Player] {
    var players: [Player] = [
        Player.new(name: "Rasmus", hp: 43),
        Player.new(name: "Resmus", hp: 43),
    ]

    func setupPlayer(_ player: Player) {
        let NUM_STARTING_ITEMS = 2
        for _ in 1...NUM_STARTING_ITEMS {
            player.take(item: Item.random())
        }
    }

    func printPlayerItems(_ player: Player) {
        func itemDescriptions(_ items: [Item]) -> String {
            return items.map { item in
                "  * \(item.rawValue) (\(item.info))"
            }.joined(separator: "\n")
        }
            
        print("\(player.name) holds:")
        print("\(itemDescriptions(player.inventory))")
    }
    
    for player in players {
        setupPlayer(player)
        printPlayerItems(player)
    }
    return players
}

func interact(_ actor: Player, _ target: Player) {
    if actor.hp - target.hp > 5 {
        actor.laugh(atPlayer: target, reason: LaughReason.TargetIsWeak)
    } else {
        actor.attack(target)
    }
}

func gameLoop(players: [Player]) {
    var numRounds = 0
    
    func playRound() {
        func getTwoPlayers() -> (Player, Player) {
            while true {
                let actor = players.randomElement()!
                let target = players.randomElement()!
                if actor !== target { return (actor, target) }
            }
        }
        let (actor, target) = getTwoPlayers()
        
        print(" ".times(8) + "--- ROUND \(numRounds) ---")
        interact(actor, target)
    }
    
    while players.contains(where: {$0.hp > 0}) {
        numRounds += 1
        playRound()
    }
}

var players = setup()
gameLoop(players: players)
