//
//  MainViewModel.swift
//  RxSwiftMVVMEXample
//
//  Created by James Kong on 11/9/2022.
//

import Foundation
import RxSwift
import RxCocoa

public func ignoreNil<A>(x: A?) -> Driver<A> {
    x.map { Driver.just($0) } ?? Driver.empty()
}

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit
#endif
public protocol MainViewModelInputs: AnyObject {
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
    func viewWillAppear()
    func viewWillDisappear()

    func setText(text: String)
    func setSelectedOption(option: String)
    func enable1(value: Bool)
    func enable2(value: Bool)
    func enable3(value: Bool)
    func getOptions2()
    func onButtonClick()
}

public protocol MainViewModelOutputs: AnyObject {
    var switch1Enabled: Driver<Bool> { get }
    var switch2Enabled: Driver<Bool> { get }
    var switch3Enabled: Driver<Bool> { get }

    var switch1Value: Driver<Bool> { get }
    var switch2Value: Driver<Bool> { get }
    var switch3Value: Driver<Bool> { get }
    var enableButton: Driver<Bool> { get}
    var text: Driver<String> { get}
    var options1: Driver<[String]> { get}
    var options2: Driver<[String]> { get}
    var selectedOption: Driver<String> { get}
    var didClickButton: Driver<Void> { get}
    var progressBarVisibility: Driver<Int> { get}
    var showBottomSheet: Driver<String> { get}
    var enable1: Driver<Bool> { get}
    var enable2: Driver<Bool> { get}
    var enable3: Driver<Bool> { get}
    var bottomsheetOptions: Driver<([String], String?)> { get}
    var reactiveText: Driver<String> { get }
}

public protocol MainViewModelType: AnyObject {
    var inputs: MainViewModelInputs { get }
    var outputs: MainViewModelOutputs { get }
}

class MainViewModel:
    NSObject,
    MainViewModelType,
    MainViewModelInputs,
    MainViewModelOutputs {


    func setText(text: String) {
        _text.accept(text)
    }

    func setSelectedOption(option: String) {
        _selectedOption.accept(option)
    }

    func enable1(value: Bool) {
        _enable1.accept(value)
    }

    func enable2(value: Bool) {
        _enable2.accept(value)
    }

    func enable3(value: Bool) {
        _enable3.accept(value)
    }

    func getOptions2() {
        _options2.accept([
        ]
        )
    }

    func onButtonClick() {
        _didClickButton.accept(())
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.getOptions2()
        }

    }

    var switch1Enabled: Driver<Bool> {
        _text.map { $0?.isEmpty == false }
            .asObservable()
            .asDriver(onErrorJustReturn: false)
            .flatMap(ignoreNil)

    }


    var switch2Enabled: Driver<Bool> {
        switch1Value
            .flatMap(ignoreNil)
            .asDriver()
    }

    var switch3Enabled: Driver<Bool> {
        switch2Value
            .flatMap(ignoreNil)
            .asDriver()
    }

    var switch1Value: Driver<Bool> {
        _enable1
            .withLatestFrom(
                _text,
                resultSelector: {
                    $0 == true && $1?.isEmpty == false
                })
            .asDriver(onErrorJustReturn: false)
            .flatMap(ignoreNil)
            .distinctUntilChanged()

    }

    var switch2Value: Driver<Bool> {
        _enable2
            .withLatestFrom(
                switch1Value,
                resultSelector: {
                    $0 == true && $1 == true
                })
            .asDriver(onErrorJustReturn: false)
            .flatMap(ignoreNil)
    }

    var switch3Value: Driver<Bool> {
        _enable3
            .withLatestFrom(
                switch2Value
                , resultSelector: {

                    $0 == true && $1 == true
                })
            .asDriver(onErrorJustReturn: false)
            .flatMap(ignoreNil)
    }

    private var _isAllEnabled: Observable<Bool> {
        BehaviorRelay
            .combineLatest(
                _enable1.compactMap{ $0 },
                _enable2.compactMap{ $0 },
                _enable3.compactMap{ $0 }
            ) { a, b, c -> Bool in
                a == true && b == true && c == true
            }
    }

    var enableButton: Driver<Bool> {
        _text.compactMap{ $0 }
            .withLatestFrom(_isAllEnabled) { text, isAllEnabled in
                return (text != "" && isAllEnabled)
            }
            .asObservable()
            .flatMap(ignoreNil)
            .asDriver(onErrorJustReturn: false)
    }

    var text: Driver<String> { _text.asDriver().flatMap(ignoreNil) }
    private var _text: BehaviorRelay<String?> = .init(value: nil)

    var options1: Driver<[String]> { _options1.asDriver().flatMap(ignoreNil) }
    private var _options1: BehaviorRelay<[String]?> = .init(value: nil)

    var selectedOption: Driver<String> { _selectedOption.asDriver().flatMap(ignoreNil) }
    private var _selectedOption: BehaviorRelay<String?> = .init(value: nil)

    var options2: Driver<[String]> { _options2.asDriver().flatMap(ignoreNil) }
    private var _options2: BehaviorRelay<[String]?> = .init(value: nil)

    var didClickButton: Driver<Void> { _didClickButton.asDriver().flatMap(ignoreNil) }
    private var _didClickButton: BehaviorRelay<Void?> = .init(value: nil)

    var progressBarVisibility: Driver<Int> { _progressBarVisibility.asDriver().flatMap(ignoreNil) }
    private var _progressBarVisibility: BehaviorRelay<Int?> = .init(value: nil)

    var showBottomSheet: Driver<String> { _showBottomSheet.asDriver().flatMap(ignoreNil) }
    private var _showBottomSheet: BehaviorRelay<String?> = .init(value: nil)

    var enable1: Driver<Bool> { _enable1.asDriver().flatMap(ignoreNil) }
    private var _enable1: BehaviorRelay<Bool?> = .init(value: nil)

    var enable2: Driver<Bool> { _enable2.asDriver().flatMap(ignoreNil) }
    private var _enable2: BehaviorRelay<Bool?> = .init(value: nil)

    var enable3: Driver<Bool> { _enable3.asDriver().flatMap(ignoreNil) }
    private var _enable3: BehaviorRelay<Bool?> = .init(value: nil)

    var bottomsheetOptions: Driver<([String], String?)> { _bottomsheetOptions.asDriver().flatMap(ignoreNil) }
    private var _bottomsheetOptions: BehaviorRelay<([String], String?)?> = .init(value: nil)


    var reactiveText: Driver<String> {
        BehaviorRelay.combineLatest(
            _text,
            _enable3)
        .map { text, enable -> String in
            if enable == false {
                return "check three check box first"
            }
            switch text {
            case "123":
                return "to short"
            case "":
                return "Text can not be empty"
            default:
                return ""
            }
        }
        .flatMap(ignoreNil)
        .asDriver(onErrorJustReturn: "")

    }

    var inputs: MainViewModelInputs { self }
    var outputs: MainViewModelOutputs { self }

    /* initialize Some Usecase or AppState */

    override init(/*Any dependency*/) {

    }

    func viewDidLoad() { }

    func viewDidAppear() { }

    func viewDidDisappear() { }

    func viewWillAppear() { }

    func viewWillDisappear() { }

    // extra Business logic
    var cursorPosition: Int? = 0
}


