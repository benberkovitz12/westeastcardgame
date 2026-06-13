import UIKit

final class MenuViewController: UIViewController {

    @IBOutlet weak var onboardingStackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveNameButton: UIButton!

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var locationStatusLabel: UILabel!
    @IBOutlet weak var westPlanetLabel: UILabel!
    @IBOutlet weak var westSideLabel: UILabel!
    @IBOutlet weak var eastPlanetLabel: UILabel!
    @IBOutlet weak var eastSideLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    private let savedNameKey = "savedPlayerName"
    private var playerName: String?
    private var playerSide: PlayerSide?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadSavedName()
        requestLocationEveryAppOpen()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedName()
        updateStartButtonState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutForLandscape()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground

        nameTextField.placeholder = "Insert name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.autocorrectionType = .no
        nameTextField.autocapitalizationType = .words
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self

        saveNameButton.setTitle("Save", for: .normal)
        saveNameButton.layer.cornerRadius = 10

        welcomeLabel.textAlignment = .center
        welcomeLabel.font = .systemFont(ofSize: 38, weight: .regular)

        locationStatusLabel.textAlignment = .center
        locationStatusLabel.numberOfLines = 2
        locationStatusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        locationStatusLabel.text = "Checking location..."

        westPlanetLabel.text = "🌍"
        westPlanetLabel.font = .systemFont(ofSize: 120)
        westPlanetLabel.textAlignment = .center
        westSideLabel.text = "West Side"
        westSideLabel.font = .systemFont(ofSize: 26, weight: .semibold)
        westSideLabel.textAlignment = .center

        eastPlanetLabel.text = "🌎"
        eastPlanetLabel.font = .systemFont(ofSize: 120)
        eastPlanetLabel.textAlignment = .center
        eastSideLabel.text = "East Side"
        eastSideLabel.font = .systemFont(ofSize: 26, weight: .semibold)
        eastSideLabel.textAlignment = .center

        startButton.setTitle("START", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
        startButton.backgroundColor = .systemBlue
        startButton.tintColor = .white
        startButton.layer.cornerRadius = 14
        startButton.layer.borderWidth = 1.5
        startButton.layer.borderColor = UIColor.black.withAlphaComponent(0.55).cgColor

        updateStartButtonState()
    }

    private func layoutForLandscape() {
        let width = view.bounds.width
        let height = view.bounds.height
        let safeTop = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom

        onboardingStackView.frame = CGRect(x: (width - 260) / 2, y: safeTop + 14, width: 260, height: 44)
        welcomeLabel.frame = CGRect(x: 20, y: safeTop + 70, width: width - 40, height: 55)
        locationStatusLabel.frame = CGRect(x: (width - 360) / 2, y: welcomeLabel.frame.maxY + 4, width: 360, height: 46)

        westPlanetLabel.frame = CGRect(x: 80, y: max(safeTop + 95, height * 0.26), width: 190, height: 150)
        westSideLabel.frame = CGRect(x: 70, y: westPlanetLabel.frame.maxY + 4, width: 210, height: 35)

        eastPlanetLabel.frame = CGRect(x: width - 270, y: westPlanetLabel.frame.minY, width: 190, height: 150)
        eastSideLabel.frame = CGRect(x: width - 280, y: eastPlanetLabel.frame.maxY + 4, width: 210, height: 35)

        let buttonWidth: CGFloat = 290
        let buttonHeight: CGFloat = 64
        startButton.frame = CGRect(
            x: (width - buttonWidth) / 2,
            y: height - safeBottom - buttonHeight - 30,
            width: buttonWidth,
            height: buttonHeight
        )
    }

    private func loadSavedName() {
        let saved = UserDefaults.standard.string(forKey: savedNameKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let saved, !saved.isEmpty {
            playerName = saved
            onboardingStackView.isHidden = true
            welcomeLabel.text = "Hi \(saved)"
        } else {
            playerName = nil
            onboardingStackView.isHidden = false
            welcomeLabel.text = "Welcome"
        }
        updateStartButtonState()
    }

    private func requestLocationEveryAppOpen() {
        locationStatusLabel.text = "Checking location..."
        playerSide = nil
        updateStartButtonState()

        LocationService.shared.requestPlayerSide { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let side):
                    self.playerSide = side
                    self.locationStatusLabel.text = "You are on the \(side.rawValue)"
                    self.highlightSelectedSide(side)
                case .failure(let error):
                    self.playerSide = nil
                    self.locationStatusLabel.text = error.userMessage
                    self.highlightSelectedSide(nil)
                }
                self.updateStartButtonState()
            }
        }
    }

    private func highlightSelectedSide(_ side: PlayerSide?) {
        let selectedAlpha: CGFloat = 1.0
        let unselectedAlpha: CGFloat = 0.25

        switch side {
        case .west:
            westPlanetLabel.alpha = selectedAlpha
            westSideLabel.alpha = selectedAlpha
            eastPlanetLabel.alpha = unselectedAlpha
            eastSideLabel.alpha = unselectedAlpha
        case .east:
            eastPlanetLabel.alpha = selectedAlpha
            eastSideLabel.alpha = selectedAlpha
            westPlanetLabel.alpha = unselectedAlpha
            westSideLabel.alpha = unselectedAlpha
        case .none:
            westPlanetLabel.alpha = selectedAlpha
            westSideLabel.alpha = selectedAlpha
            eastPlanetLabel.alpha = selectedAlpha
            eastSideLabel.alpha = selectedAlpha
        }
    }

    private func updateStartButtonState() {
        let canStart = (playerName?.isEmpty == false) && playerSide != nil
        startButton.isEnabled = canStart
        startButton.alpha = canStart ? 1.0 : 0.45
    }

    @objc private func appBecameActive() {
        // Only refresh location when the menu is actually visible.
        // If the user is in the middle of the game, do not interrupt it.
        if presentedViewController == nil {
            requestLocationEveryAppOpen()
        }
    }

    @IBAction func saveNameTapped(_ sender: UIButton) {
        let typedName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !typedName.isEmpty else {
            nameTextField.shake()
            return
        }

        UserDefaults.standard.set(typedName, forKey: savedNameKey)
        nameTextField.resignFirstResponder()
        loadSavedName()
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard let playerName, let playerSide else {
            updateStartButtonState()
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let gameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else {
            return
        }

        gameVC.playerName = playerName
        gameVC.playerSide = playerSide
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }
}

extension MenuViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveNameTapped(saveNameButton)
        return true
    }
}

private extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.35
        animation.values = [-8, 8, -6, 6, -3, 3, 0]
        layer.add(animation, forKey: "shake")
    }
}
