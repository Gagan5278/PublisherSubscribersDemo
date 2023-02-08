//
//  ViewController.swift
//  PublisherSubscriber
//
//  Created by Gagan Vishal  on 2023/02/08.
//

import UIKit
import Combine
class FirstViewController: UIViewController {
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var userNameTextfield: UITextField!
    
    @Published var userNameString: String?
    @Published var passwordString: String?
    @Published var confirmPasswordString: String?

    var usernamePublisher: AnyPublisher<String?, Never> {
        return $userNameString
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { userName in
                Future { promise in
                    promise(.success(userName))
                }
            }
            .eraseToAnyPublisher()
    }
    
    var passwordEntryConfirmation: AnyPublisher<String?, Never> {
        Publishers
            .CombineLatest($passwordString, $confirmPasswordString)
            .map{ (password1, confirmPassword)  in
                guard password1 == confirmPassword, password1 != nil, !password1!.isEmpty else {
                    return nil
                }
                return password1
            }
            .map({ passwordEnetered in
                passwordEnetered ?? nil
            })
            .eraseToAnyPublisher()
    }
    
    var formEnterValidator: AnyPublisher<String?, Never> {
        Publishers
            .CombineLatest(usernamePublisher, passwordEntryConfirmation)
            .map { (name, pass) in
                guard (name != nil && pass != nil) else {
                    return nil
                }
                return name
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var cancellable: AnyCancellable?
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        cancellable = formEnterValidator
            .map({$0 != nil})
            .assign(to: \.isEnabled, on: sendButton)
    }
}


extension FirstViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = textField.text ?? ""
        let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)
        if textField == userNameTextfield {
            userNameString = text
        } else if textField == passwordTextfield {
            passwordString = text
        } else if textField == confirmPasswordTextfield  {
            confirmPasswordString = text
        }
        return true
    }
}
