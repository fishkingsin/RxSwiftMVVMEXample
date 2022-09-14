//
//  ViewController.swift
//  RxSwiftMVVMEXample
//
//  Created by James Kong on 11/9/2022.
//

import UIKit
import RxSwift
class ViewController: UIViewController {

    var textField: UITextField = {
       let view = UITextField()
        view.placeholder = "Enter Text"
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: view.frame.height - 1, width: view.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.black.cgColor
        view.borderStyle = .none
        view.keyboardType = .decimalPad
        view.backgroundColor = .darkGray
        view.layer.addSublayer(bottomLine)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var switch1: UISwitch = {
       let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var switch2: UISwitch = {
       let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var switch3: UISwitch = {
       let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var button: UIButton = {
       let view = UIButton()
        view.setTitleColor(.blue, for: .normal)
        view.setTitleColor(.lightGray, for: .disabled)
        view.setTitle("SHOW BOTTOM SHEET", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var label: UILabel = {
       let view = UILabel()
        view.text = "Default Text"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    private(set) var viewModel: MainViewModelType!


    /// Combine related:  handle lifecycle of binding/subscription
    private var bag = DisposeBag()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        viewModel = MainViewModel()
    }

    required init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
        viewModel = MainViewModel()
    }
    /**
     - Remark: It should call only once and before ViewController calling viewDidLoad(), In ViewDidLoad, it call bindViewModel().
     */
    public func setupViewModel(_ viewModel: MainViewModelType) {
        self.viewModel = viewModel
    }

    /// Light or Dark Mode handling
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewsAndConstraints()
        setupLayout()
        setupLocalization()
        bindViewModel()
        viewModel.inputs.viewDidLoad()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewWillAppear()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppear()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.inputs.viewDidDisappear()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.inputs.viewWillDisappear()
    }

    private func setupNavigationBar() {

    }

    private func setupViewsAndConstraints() {
        self.view.backgroundColor = .white
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(switch1)
        stackView.addArrangedSubview(switch2)
        stackView.addArrangedSubview(switch3)
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(label)

        scrollView.addSubview(stackView)
        view.addSubview(scrollView)



        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupLayout() {
        // TODO: setup colors, textColors, backgroundColors, images
    }

    private func setupLocalization() {
        // TODO: get localized string from CHFLanguage.getText(key:"__KEY__", file: CHIEF_UI_STRINGS)
    }

    private func bindViewModel() {


        button.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.inputs.onButtonClick()
        }).disposed(by: bag)

        self.viewModel.inputs.setText(text: textField.text ?? "")

        textField
            .rx
            .text
            .asDriver()
            .asObservable()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.viewModel.inputs.setText(text: text ?? "")
            }).disposed(by: bag)

        switch1.rx.isOn
            .subscribe(onNext: { [weak self] isOn in
            guard let self = self else { return }
            print("\(isOn)")
            self.viewModel.inputs.enable1(value: isOn)
        }).disposed(by: bag)

        switch2.rx.isOn
            .subscribe(onNext: { [weak self] isOn in
            guard let self = self else { return }
            print("\(isOn)")
            self.viewModel.inputs.enable2(value: isOn)
        }).disposed(by: bag)

        switch3.rx.isOn
            .subscribe(onNext: { [weak self] isOn in
            guard let self = self else { return }
            print("\(isOn)")
            self.viewModel.inputs.enable3(value: isOn)
        }).disposed(by: bag)

        viewModel
            .outputs
            .switch1Enabled
            .asObservable()
            .subscribe(onNext: { [weak self] enabled in
                guard let self = self else { return }
                self.switch1.isEnabled = enabled

                if enabled == false {
                    self.switch2.isEnabled = enabled
                    self.switch3.isEnabled = enabled
                    self.switch1.setOn(false, animated: true)
                    self.switch2.setOn(false, animated: true)
                    self.switch3.setOn(false, animated: true)
                }
            }).disposed(by: bag)

        viewModel
            .outputs
            .switch2Enabled
            .asObservable()
            .subscribe(onNext: { [weak self] enabled in
                guard let self = self else { return }
                self.switch2.isEnabled = enabled

                if enabled == false {
                    self.switch3.isEnabled = enabled
                    self.switch2.setOn(false, animated: true)
                    self.switch3.setOn(false, animated: true)
                }
            }).disposed(by: bag)

        viewModel
            .outputs
            .switch3Enabled
            .asObservable()
            .subscribe(onNext: { [weak self] enabled in
                guard let self = self else { return }
                self.switch3.isEnabled = enabled
                if enabled == false {
                    self.switch3.setOn(false, animated: true)
                }
            }).disposed(by: bag)

        viewModel
            .outputs
            .switch1Value
            .asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.switch1.isOn = value
            }).disposed(by: bag)

        viewModel
            .outputs
            .switch2Value
            .asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.switch2.isOn = value
            }).disposed(by: bag)

        viewModel
            .outputs
            .switch3Value
            .asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.switch3.isOn = value
            }).disposed(by: bag)


        viewModel
            .outputs
            .enable1
            .asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                print("enableButton \(value)")
                self.switch1.isOn = value
            }).disposed(by: bag)

        viewModel
            .outputs
            .enableButton
            .asObservable()
            .subscribe(onNext: { [weak self] enabled in
                guard let self = self else { return }
                print("enableButton \(enabled)")
                self.button.isEnabled = enabled
            }).disposed(by: bag)


        viewModel
            .outputs
            .didClickButton
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
//                self.presentPanModal(MySelectionBottomSheet(viewModel: self.viewModel))
            }).disposed(by: bag)


        viewModel
            .outputs
            .reactiveText
            .asObservable()
            .subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
                self.label.text = text
            }).disposed(by: bag)
    }

}

