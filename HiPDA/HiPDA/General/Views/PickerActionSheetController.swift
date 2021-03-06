//
//  PickerActionSheetController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/11.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 选择结束的block
typealias PickerSelectedCompletionHandler = (Int?) -> Void

/// 包含Picker选择器的ActionSheetController
///
/// 在present的时候animation请用false！
class PickerActionSheetController: BaseViewController, StoryboardLoadable {
    /// 选择结束时的CompletionHandler
    var selectedCompletionHandler: PickerSelectedCompletionHandler?
    
    /// picker的标题数组
    var pickerTitles: [String]!
    
    /// 初始的选择下标
    var initialSelelctionIndex: Int!
    
    /// 容器视图的底constraint
    @IBOutlet weak var containerStackViewBottomConstraint: NSLayoutConstraint!
    
    /// 容器视图的高度constraint
    @IBOutlet weak var containerStackViewHeightConstraint: NSLayoutConstraint!
    
    /// pickerView
    @IBOutlet weak var pickerView: UIPickerView!
    
    /// 分割线的高度constraint
    @IBOutlet weak var seperatorHeightConstraint: NSLayoutConstraint!
    
    /// 背景被点击
    @IBOutlet var tapBackground: UITapGestureRecognizer!
    
    /// 取消按钮
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    
    /// 确定按钮
    @IBOutlet weak var submitBarButtonItem: UIBarButtonItem!
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        useCustomViewControllerTransitioningAnimator = false
        pickerView.selectRow(initialSelelctionIndex ?? 0, inComponent: 0, animated: true)
        
        let commands: [Observable<Bool>] = [
            tapBackground.rx.event.map { _ in false },
            cancelBarButtonItem.rx.tap.map { _ in false },
            submitBarButtonItem.rx.tap.map { _ in true }
        ]
        
        Observable.from(commands).merge().subscribe(onNext: { [weak self] submit in
            guard let `self` = self,
                let selectedCompletionHandler = self.selectedCompletionHandler
                else { return }
            
            self.containerStackViewBottomConstraint.constant = -self.containerStackViewHeightConstraint.constant
            UIView.animate(withDuration: C.UI.animationDuration, animations: {
                self.view.backgroundColor = UIColor.clear
                self.view.layoutIfNeeded()
            }, completion: { _ in
                if submit {
                    selectedCompletionHandler(self.pickerView.selectedRow(inComponent: 0))
                } else {
                    selectedCompletionHandler(nil)
                }
            })
        }).addDisposableTo(disposeBag)
    }
    
    override func setupConstraints() {
        seperatorHeightConstraint.constant = 1.0 / UIScreen.main.scale
        containerStackViewHeightConstraint.constant -= 1.0 / UIScreen.main.scale
        containerStackViewBottomConstraint.constant = -containerStackViewHeightConstraint.constant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        containerStackViewBottomConstraint.constant = 0.0
        UIView.animate(withDuration: C.UI.animationDuration) {
            self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            self.view.layoutIfNeeded()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return presentingViewController?.preferredStatusBarStyle ?? .lightContent
    }
}

// MARK: - UIPickerViewDataSource
extension PickerActionSheetController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerTitles.count
    }
}

// MARK: - UIPickerViewDelegate
extension PickerActionSheetController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerTitles.safe[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        label.text = pickerTitles.safe[row]
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17.0)
        
        return label
    }
}
