//
//  ViewController.swift
//  RxTest
//
//  Created by naomi-hidaka on 2017/05/01.
//  Copyright © 2017年 naomi-hidaka. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

let minimalUsernameLength = 5
let minimalPasswordLength = 5

enum TestError: Error {
    case dummyError
    case dummyError1
    case dummyError2
}

class ViewController : UIViewController {

    let errorsSubject = PublishSubject<Error>()
    let disposeBag = DisposeBag()
    var errors: Observable<Error>?

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidOutlet: UILabel!

    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidOutlet: UILabel!

    @IBOutlet weak var doSomethingOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        errors = errorsSubject.asObservable()

        usernameValidOutlet.text = "Username has to be at least \(minimalUsernameLength) characters"
        passwordValidOutlet.text = "Password has to be at least \(minimalPasswordLength) characters"

        let usernameValid = usernameOutlet.rx.text.orEmpty
            .map { text -> Bool in
                print("[execute validation]")
                return text.characters.count >= minimalUsernameLength
            }.shareReplay(1) // without this map would be executed once for each binding, rx is stateless by default

        let passwordValid = passwordOutlet.rx.text.orEmpty
            .map { $0.characters.count >= minimalPasswordLength }
            .shareReplay(1)

        let everythingValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .shareReplay(1)

        usernameValid
            .bind(to: passwordOutlet.rx.isEnabled)
            .addDisposableTo(disposeBag)

        usernameValid
            .bind(to: usernameValidOutlet.rx.isHidden)
            .addDisposableTo(disposeBag)

        passwordValid
            .bind(to: passwordValidOutlet.rx.isHidden)
            .addDisposableTo(disposeBag)

        everythingValid
            .bind(to: doSomethingOutlet.rx.isEnabled)
            .addDisposableTo(disposeBag)

        doSomethingOutlet.rx.tap
            .subscribe(onNext: { [weak self] in self?.showAlert() })
            .addDisposableTo(disposeBag)

        rxTest()
        _ = errorsSubject.subscribe(onNext: { error in
            print(error)
        })


    }

    deinit {

    }

    func rxTest() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            self.errorsSubject.onNext(TestError.dummyError)
            print("wwwwwwwww")
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
            print("10")
            self.errorsSubject.onNext(TestError.dummyError)
        })
    }

    func showAlert() {
        let alertView = UIAlertView(
            title: "RxExample",
            message: "This is wonderful",
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        
        alertView.show()
    }
    
}
