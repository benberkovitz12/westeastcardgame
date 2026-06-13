import UIKit

final class ResultViewController: UIViewController {

    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var backToMenuButton: UIButton!

    var winnerText: String = "Winner"
    var scoreText: String = "score: 0"

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutForLandscape()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground

        winnerLabel.text = winnerText
        winnerLabel.textAlignment = .center
        winnerLabel.font = .systemFont(ofSize: 34, weight: .bold)

        scoreLabel.text = scoreText
        scoreLabel.textAlignment = .center
        scoreLabel.font = .systemFont(ofSize: 32, weight: .bold)

        backToMenuButton.setTitle("BACK TO MENU", for: .normal)
        backToMenuButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        backToMenuButton.backgroundColor = .systemBlue
        backToMenuButton.tintColor = .white
        backToMenuButton.layer.cornerRadius = 10
        backToMenuButton.layer.borderWidth = 1
        backToMenuButton.layer.borderColor = UIColor.black.withAlphaComponent(0.45).cgColor
    }

    private func layoutForLandscape() {
        let width = view.bounds.width
        let height = view.bounds.height

        winnerLabel.frame = CGRect(x: 20, y: height * 0.26, width: width - 40, height: 50)
        scoreLabel.frame = CGRect(x: 20, y: winnerLabel.frame.maxY + 48, width: width - 40, height: 50)
        backToMenuButton.frame = CGRect(x: (width - 210) / 2, y: scoreLabel.frame.maxY + 48, width: 210, height: 62)
    }

    @IBAction func backToMenuTapped(_ sender: UIButton) {
        // Result VC is presented by Game VC, and Game VC is presented by Menu VC.
        // This dismisses all modals and returns to the menu.
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            root.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
