//
//  LoginViewController.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 12..
//

import UIKit
import ClosureLayout
import AuthenticationServices
import KeychainAccess
import OneSignal

class LoginViewController: UIViewController {
    
    // MARK: - Private Properties
    private let loginDataSource: LoginDataSource = LoginRemoteDataSource()
    private let keychain = Keychain()
    private lazy var requestState = String.random(length: 128)

    // MARK: - Injected Properties
    weak var coordinator: LoginCoordinator?
    
    // MARK: - UI Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var darkmodeLabel: UILabel!
    @IBOutlet weak var darkmodeSwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    lazy var loginButton = createLoginButton(style: .black)
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        darkmodeSwitch.isOn = !Theme.isDefault
        activityIndicator.isHidden = true
        setupViews()
    }
    
    // MARK: Setup
    private func createLoginButton(style: ASAuthorizationAppleIDButton.Style) -> ASAuthorizationAppleIDButton{
        let button = ASAuthorizationAppleIDButton(type: .default, style: style)
        button.layout {
            $0.width == 200
            $0.height == 45
        }
        button.cornerRadius = 11
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }
    
    private func setupViews() {
        view.backgroundColor = .mainColor
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .thirdText
        loginLabel.textColor = .thirdText
        darkmodeLabel.textColor = .thirdText
        activityIndicator.color = Theme.isDefault ? .darkishGray : .lightGray
        loginButton.removeFromSuperview()
        loginButton = createLoginButton(style: Theme.isDefault ? .black : .white)
        loginStackView.insertArrangedSubview(loginButton, at: 0)
    }
    
    // MARK: - Actions
    @objc
    func handleLogin() {
        activityIndicator.isHidden = false
        loginButton.isEnabled = false
        activityIndicator.startAnimating()
        loginDataSource.startSession { (sessionResponse, error) in
            guard let sessionResponse = sessionResponse else {
                self.activityIndicator.isHidden = true
                self.loginButton.isEnabled = true
                Banner.showError()
                return
            }
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.email]
            request.nonce = sessionResponse.nonce
            request.state = self.requestState
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    @IBAction func darkmodeSwitchChanged(_ sender: UISwitch) {
        Theme.change()
        setupViews()
    }
    
    private func login(userId: String, token: String, state: String?) {
        guard state == requestState else {
            Banner.showError()
            return
        }
        
        let request = LoginRequest(userId: userId, identityToken: token)
        loginDataSource.login(request: request) { response, error in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.loginButton.isEnabled = true
            guard let response = response else {
                Banner.showError()
                return
            }
            print(response.token)
            self.keychain["token"] = response.token
            OneSignal.setExternalUserId(userId)
            self.coordinator?.loginSuccess()
        }
    }
}

// MARK: - ASAuthorizationController Delegates
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        let credential = authorization.credential as? ASAuthorizationAppleIDCredential
        guard let tokenData = credential?.identityToken,
              let token = String(data: tokenData, encoding: .utf8),
              let userId = credential?.user,
              let state = credential?.state else {
            Banner.showError()
            return
        }
        login(userId: userId, token: token, state: state)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        loginButton.isEnabled = true
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

