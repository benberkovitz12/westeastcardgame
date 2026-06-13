import UIKit

final class GameViewController: UIViewController {

    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var pcNameLabel: UILabel!
    @IBOutlet weak var pcScoreLabel: UILabel!
    @IBOutlet weak var playerCardImageView: UIImageView!
    @IBOutlet weak var pcCardImageView: UIImageView!
    @IBOutlet weak var timerIconLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!

    var playerName: String = "Player"
    var playerSide: PlayerSide = .west

    private let winningScore = 10
    private let gameEngine = GameEngine()

    private var playerScore = 0
    private var pcScore = 0
    private var hasStarted = false
    private var gameFinished = false

    private var scheduledWorkItems: [DispatchWorkItem] = []
    private var countdownTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !hasStarted {
            hasStarted = true
            startGameAutomatically()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutForLandscape()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelAllTimers()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground

        playerNameLabel.text = "\(playerName)\n\(playerSide.rawValue)"
        playerNameLabel.numberOfLines = 2
        playerNameLabel.textAlignment = .center
        playerNameLabel.font = .systemFont(ofSize: 18, weight: .medium)

        pcNameLabel.text = "PC\n\(playerSide.opposite.rawValue)"
        pcNameLabel.numberOfLines = 2
        pcNameLabel.textAlignment = .center
        pcNameLabel.font = .systemFont(ofSize: 18, weight: .medium)

        playerScoreLabel.text = "0"
        playerScoreLabel.textAlignment = .center
        playerScoreLabel.font = .systemFont(ofSize: 34, weight: .bold)

        pcScoreLabel.text = "0"
        pcScoreLabel.textAlignment = .center
        pcScoreLabel.font = .systemFont(ofSize: 34, weight: .bold)

        [playerCardImageView, pcCardImageView].forEach { imageView in
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
            imageView?.layer.cornerRadius = 12
            imageView?.layer.shadowColor = UIColor.black.cgColor
            imageView?.layer.shadowOpacity = 0.12
            imageView?.layer.shadowRadius = 8
            imageView?.layer.shadowOffset = CGSize(width: 0, height: 4)
        }

        timerIconLabel.text = "⏱"
        timerIconLabel.textAlignment = .center
        timerIconLabel.font = .systemFont(ofSize: 48, weight: .regular)

        countdownLabel.text = "5"
        countdownLabel.textAlignment = .center
        countdownLabel.font = .systemFont(ofSize: 44, weight: .bold)

        // Hide the middle round text completely
        roundLabel.text = ""
        roundLabel.isHidden = true

        setCardBacks(animated: false)
    }

    private func layoutForLandscape() {
        let width = view.bounds.width
        let height = view.bounds.height
        let safeTop = view.safeAreaInsets.top

        playerNameLabel.frame = CGRect(x: 28, y: safeTop + 10, width: 150, height: 48)
        playerScoreLabel.frame = CGRect(x: 28, y: playerNameLabel.frame.maxY + 2, width: 150, height: 42)

        pcNameLabel.frame = CGRect(x: width - 178, y: safeTop + 10, width: 150, height: 48)
        pcScoreLabel.frame = CGRect(x: width - 178, y: pcNameLabel.frame.maxY + 2, width: 150, height: 42)

        let cardWidth = min(width * 0.28, 250)
        let cardHeight = min(height * 0.70, 320)
        let cardY = (height - cardHeight) / 2 + 12

        playerCardImageView.frame = CGRect(x: width * 0.23, y: cardY, width: cardWidth, height: cardHeight)
        pcCardImageView.frame = CGRect(x: width * 0.60, y: cardY, width: cardWidth, height: cardHeight)

        timerIconLabel.frame = CGRect(x: (width - 90) / 2, y: height * 0.35, width: 90, height: 60)
        countdownLabel.frame = CGRect(x: (width - 90) / 2, y: timerIconLabel.frame.maxY - 2, width: 90, height: 58)

        // Keep roundLabel hidden and out of the way
        roundLabel.frame = .zero
    }

    private func startGameAutomatically() {
        playerScore = 0
        pcScore = 0
        gameFinished = false

        playerScoreLabel.text = "0"
        pcScoreLabel.text = "0"

        gameEngine.resetDeck()
        setCardBacks(animated: false)

        schedule(after: 0.6) { [weak self] in
            self?.startNextRound()
        }
    }

    private func startNextRound() {
        guard !gameFinished else { return }

        if playerScore >= winningScore || pcScore >= winningScore {
            finishGame()
            return
        }

        guard let cards = gameEngine.dealTwoCards() else {
            finishGame()
            return
        }

        reveal(playerCard: cards.player, pcCard: cards.computer)
        scoreRound(playerCard: cards.player, pcCard: cards.computer)
        startCountdown(from: 5)

        // Let the cards stay visible for 3 seconds
        schedule(after: 3.0) { [weak self] in
            guard let self = self, !self.gameFinished else { return }

            if self.playerScore >= self.winningScore || self.pcScore >= self.winningScore {
                self.finishGame()
            } else {
                self.setCardBacks(animated: true)
            }
        }

        // After 5 seconds, either continue or finish
        schedule(after: 5.0) { [weak self] in
            guard let self = self, !self.gameFinished else { return }

            if self.playerScore >= self.winningScore || self.pcScore >= self.winningScore {
                self.finishGame()
            } else {
                self.startNextRound()
            }
        }
    }

    private func reveal(playerCard: Card, pcCard: Card) {
        setCard(playerCard, on: playerCardImageView, animated: true)
        setCard(pcCard, on: pcCardImageView, animated: true)
    }

    private func scoreRound(playerCard: Card, pcCard: Card) {
        if playerCard.value > pcCard.value {
            playerScore += 1
        } else if pcCard.value > playerCard.value {
            pcScore += 1
        }
        // If equal, do nothing

        playerScoreLabel.text = "\(playerScore)"
        pcScoreLabel.text = "\(pcScore)"
    }

    private func setCardBacks(animated: Bool) {
        setBack(on: playerCardImageView, animated: animated)
        setBack(on: pcCardImageView, animated: animated)
    }

    private func setCard(_ card: Card, on imageView: UIImageView, animated: Bool) {
        let changeImage = {
            if let realImage = UIImage(named: card.imageName) {
                imageView.image = realImage
                imageView.backgroundColor = .clear
            } else {
                imageView.image = Self.makePlaceholderCard(text: card.shortName)
                imageView.backgroundColor = .clear
                print("Missing card image asset: \(card.imageName)")
            }
        }

        if animated {
            UIView.transition(
                with: imageView,
                duration: 0.45,
                options: .transitionFlipFromLeft,
                animations: changeImage
            )
        } else {
            changeImage()
        }
    }

    private func setBack(on imageView: UIImageView, animated: Bool) {
        let changeImage = {
            if let backImage = UIImage(named: "card_back") {
                imageView.image = backImage
                imageView.backgroundColor = .clear
            } else {
                imageView.image = Self.makePlaceholderCard(text: "🂠")
                imageView.backgroundColor = .clear
                print("Missing card back image asset: card_back")
            }
        }

        if animated {
            UIView.transition(
                with: imageView,
                duration: 0.45,
                options: .transitionFlipFromRight,
                animations: changeImage
            )
        } else {
            changeImage()
        }
    }

    private func startCountdown(from seconds: Int) {
        countdownTimer?.invalidate()

        var current = seconds
        countdownLabel.text = "\(current)"

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            current -= 1
            self.countdownLabel.text = "\(max(current, 0))"

            if current <= 0 {
                timer.invalidate()
            }
        }
    }

    private func finishGame() {
        guard !gameFinished else { return }
        gameFinished = true

        cancelAllTimers()

        let winnerText: String
        let winnerScore: Int

        if playerScore >= winningScore {
            winnerText = "Winner: \(playerName)"
            winnerScore = playerScore
        } else if pcScore >= winningScore {
            winnerText = "Winner: PC"
            winnerScore = pcScore
        } else if playerScore > pcScore {
            winnerText = "Winner: \(playerName)"
            winnerScore = playerScore
        } else if pcScore > playerScore {
            winnerText = "Winner: PC"
            winnerScore = pcScore
        } else {
            winnerText = "Tie"
            winnerScore = playerScore
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let resultVC = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else {
            return
        }

        resultVC.winnerText = winnerText
        resultVC.scoreText = "score: \(winnerScore)"
        resultVC.modalPresentationStyle = .fullScreen

        present(resultVC, animated: true)
    }

    private func schedule(after delay: TimeInterval, action: @escaping () -> Void) {
        let item = DispatchWorkItem(block: action)
        scheduledWorkItems.append(item)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    private func cancelAllTimers() {
        countdownTimer?.invalidate()
        countdownTimer = nil

        scheduledWorkItems.forEach { $0.cancel() }
        scheduledWorkItems.removeAll()
    }

    private static func makePlaceholderCard(text: String) -> UIImage {
        let size = CGSize(width: 260, height: 360)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: size)

            let rounded = UIBezierPath(
                roundedRect: rect.insetBy(dx: 5, dy: 5),
                cornerRadius: 18
            )

            UIColor.systemGray6.setFill()
            rounded.fill()

            UIColor.systemGray3.setStroke()
            rounded.lineWidth = 4
            rounded.stroke()

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 72, weight: .bold),
                .foregroundColor: UIColor.label
            ]

            let textSize = text.size(withAttributes: attributes)

            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}
