//
//  hpOTPView.swift
//  hpOTPView
//
//  Created by datt on 13/11/19.
//  Copyright © 2019 datt. All rights reserved.
//

import UIKit

public protocol HPOTPViewDelegate {
    func hpOTPViewAddText(_ text:String , at position:Int)
    func hpOTPViewRemoveText(_ text:String , at position:Int)
    func hpOTPViewChangePositionAt(_ position:Int)
    func hpOTPViewBecomeFirstResponder()
    func hpOTPViewResignFirstResponder()
}

@IBDesignable open class HPOTPView: UIView {
    
    /** The number of textField that will be put in the hpOTPView */
    @IBInspectable open dynamic var count: Int = 4 {
        didSet {
            if isLoaded {
                isLoaded = false
                let isFirstResponder = arrTextFields.filter({$0.isFirstResponder}).first != nil
                initialization()
                if isFirstResponder {
                    becomeFirstResponder()
                }
            }
        }
    }
    
    /** Spaceing between textField in the hpOTPView */
    @IBInspectable open dynamic var spacing: CGFloat = 8
    
    /** Text color for the textField */
    @IBInspectable open dynamic var textColorTextField: UIColor = UIColor.black
    
    /** Text font for the textField */
    @IBInspectable open dynamic var fontTextField: UIFont = UIFont.systemFont(ofSize: 17
    )
    
    /** Placeholder */
    @IBInspectable open dynamic var placeholder: String = ""
    
    /** Placeholder text color for the textField */
    @IBInspectable open dynamic var placeholderTextColor: UIColor = UIColor.gray
    
    /** Circle textField */
    @IBInspectable open dynamic var isCircleTextField: Bool = false
    
    /** Allow only Bottom Line for the TextField */
    @IBInspectable open dynamic var isBottomLineTextField: Bool = false
    
    /** Background Image for all  textFields */
    @IBInspectable open dynamic var backGroundImageTextField: UIImage?
    
    /** Background color for the textField */
    @IBInspectable open dynamic var backGroundColorTextField: UIColor = UIColor.clear
    
    /** Background color for the filled textField */
    @IBInspectable open dynamic var backGroundColorFilledTextField: UIColor?
    
    /** Border color for the TextField */
    @IBInspectable open dynamic var borderColorTextField: UIColor?
    
    /** Border color for the TextField */
    @IBInspectable open dynamic var selectedBorderColorTextField: UIColor?
    
    /** Border width for the TextField */
    @IBInspectable open dynamic var borderWidthTextField: CGFloat = 0.0
    
    /** Border width for the TextField */
    @IBInspectable open dynamic var selectedBorderWidthTextField: CGFloat = 0.0
    
    /** Corner radius for the TextField */
    @IBInspectable open dynamic var cornerRadiusTextField: CGFloat = 0.0
    
    /** Tint/cursor color for the TextField */
    @IBInspectable open dynamic var tintColorTextField: UIColor = UIColor.systemBlue
    
    /** Shadow Radius for the TextField */
    @IBInspectable open dynamic var shadowRadiusTextField: CGFloat = 0.0
    
    /** Shadow Opacity for the TextField */
    @IBInspectable open dynamic var shadowOpacityTextField: Float = 0.0
    
    /** Shadow Offset Size for the TextField */
    @IBInspectable open dynamic var shadowOffsetSizeTextField: CGSize = .zero
    
    /** Shadow color for the TextField */
    @IBInspectable open dynamic var shadowColorTextField: UIColor?
    
    /** Dismiss keyboard with enter last character*/
    @IBInspectable open dynamic var dismissOnLastEntry: Bool = false
    
    /** Secure Text Entry*/
    @IBInspectable open dynamic var isSecureTextEntry: Bool = false
    
    /** Hide cursor*/
    @IBInspectable open dynamic var isCursorHidden: Bool = false
    
    /** Dark keyboard*/
    @IBInspectable open dynamic var isDarkKeyboard: Bool = false
    
    open dynamic var textEdgeInsets : UIEdgeInsets?
    open dynamic var editingTextEdgeInsets : UIEdgeInsets?
    
    open dynamic var inputViewForAll: UIView?
    open dynamic var inputAccessoryViewForAll: UIView?
    
    open dynamic var hpOTPViewDelegate : HPOTPViewDelegate?
    open dynamic var keyboardType:UIKeyboardType = UIKeyboardType.asciiCapableNumberPad
    
    open dynamic var text : String? {
        get {
            var str = ""
            arrTextFields.forEach { str.append($0.text ?? "") }
            return str
        } set {
            arrTextFields.forEach { $0.text = nil }
            for i in 0 ..< arrTextFields.count {
                if i < (newValue?.count ?? 0) {
                    if let txt = newValue?[i..<i+1] , let code = Int(txt) {
                        arrTextFields[i].text = String(code)
                    }
                }
            }
        }
    }
    
    fileprivate var arrTextFields : [HTPBackTextField] = []
    fileprivate var isLoaded = false
    /** Override coder init, for IB/XIB compatibility */
    #if !TARGET_INTERFACE_BUILDER
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /** Override common init, for manual allocation */
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.initialization()
    }
    #endif
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        initialization()
    }
    
    func initialization() {
        if isLoaded { return }
        arrTextFields.forEach{ $0.removeFromSuperview() }
        arrTextFields = []
        
        let sizeTextField = (self.bounds.width/CGFloat(count)) - (spacing)
        
        for i in 1 ... count {
            let textField = HTPBackTextField()
            textField.delegate = self
            textField.HTPBackDelegate = self
            textField.hpOTPView = self
            textField.borderStyle = .none
            textField.tag = i * 1000
            textField.tintColor = tintColorTextField
            textField.backgroundColor = backGroundColorTextField
            textField.background = backGroundImageTextField
            textField.isSecureTextEntry = isSecureTextEntry
            textField.font = fontTextField
            textField.keyboardAppearance = isDarkKeyboard ? .dark : .default
            textField.inputView = inputViewForAll
            textField.inputAccessoryView = inputAccessoryViewForAll
            if isCursorHidden {
                textField.tintColor = .clear
            } else {
                textField.tintColor = tintColor
            }
            if isBottomLineTextField {
                let border = CALayer()
                border.name = "bottomBorderLayer"
                textField.removePreviouslyAddedLayer(name: border.name ?? "")
                border.backgroundColor = borderColorTextField?.cgColor
                border.frame = CGRect(x: 0, y: sizeTextField - borderWidthTextField,width : sizeTextField ,height: borderWidthTextField)
                textField.layer.addSublayer(border)
            } else {
                textField.layer.borderColor = borderColorTextField?.cgColor
                textField.layer.borderWidth = borderWidthTextField
                if isCircleTextField {
                    textField.layer.cornerRadius = sizeTextField / 2
                } else {
                    textField.layer.cornerRadius = cornerRadiusTextField
                }
            }
            textField.layer.shadowRadius = shadowRadiusTextField
            if let shadowColorTextField = shadowColorTextField {
                textField.layer.shadowColor = shadowColorTextField.cgColor
            }
            textField.layer.shadowOpacity = shadowOpacityTextField
            textField.layer.shadowOffset = shadowOffsetSizeTextField
            
            textField.textColor = textColorTextField
            textField.textAlignment = .center
            textField.keyboardType = keyboardType
            if #available(iOS 12.0, *) {
                textField.textContentType = .oneTimeCode
            }
            
            if placeholder.count > i - 1 {
                textField.attributedPlaceholder = NSAttributedString(string: placeholder[i - 1],
                attributes: [NSAttributedString.Key.foregroundColor: placeholderTextColor])
            }
            
            textField.frame = CGRect(x:(CGFloat(i-1) * sizeTextField) + (CGFloat(i) * spacing/2) + (CGFloat(i-1) * spacing/2)  , y: (self.bounds.height - sizeTextField)/2 , width: sizeTextField, height: sizeTextField)
            
            arrTextFields.append(textField)
            self.addSubview(textField)
            if isCursorHidden {
                let tapView = UIView(frame: self.bounds)
                tapView.backgroundColor = .clear
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                tapView.addGestureRecognizer(tap)
                self.addSubview(tapView)
            }
            isLoaded = true
        }
    }
    
//    // Only override draw() if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//
//        super.draw(rect)
//    }

    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        if arrTextFields.count != count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.becomeFirstResponder()
            }
            return false
        }
        if isCursorHidden {
            for i in 0 ..< arrTextFields.count {
                if arrTextFields[i].text?.count == 0 {
                    _ = arrTextFields[i].becomeFirstResponder()
                    break
                } else if (arrTextFields.count - 1) == i {
                    _ = arrTextFields[i].becomeFirstResponder()
                    break
                }
            }
        } else {
            _ = arrTextFields.first?.becomeFirstResponder()
        }
        hpOTPViewDelegate?.hpOTPViewBecomeFirstResponder()
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        arrTextFields.forEach { (textField) in
            _ = textField.resignFirstResponder()
        }
        hpOTPViewDelegate?.hpOTPViewResignFirstResponder()
        return super.resignFirstResponder()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        _ = self.becomeFirstResponder()
    }
    
    open func validate() -> Bool {
        var isValid = true
        arrTextFields.forEach { (textField) in
            if Int(textField.text ?? "") == nil {
                isValid = false
            }
        }
        return isValid
    }
}

extension HPOTPView : UITextFieldDelegate , HTPBackTextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        hpOTPViewDelegate?.hpOTPViewChangePositionAt(textField.tag/1000 - 1)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.trimmingCharacters(in: CharacterSet.whitespaces).count != 0 {
            textField.text = string
            if textField.tag < count*1000 {
                let next = textField.superview?.viewWithTag((textField.tag/1000 + 1)*1000)
                next?.becomeFirstResponder()
            } else if textField.tag == count*1000 && dismissOnLastEntry {
                textField.resignFirstResponder()
            }
        } else if string.count == 0 { // is backspace
            textField.text = ""
        }
        hpOTPViewDelegate?.hpOTPViewAddText(text ?? "", at: textField.tag/1000 - 1)
        return false
    }
    
    func textFieldDidDelete(_ textField: UITextField) {
        if textField.tag > 1000 , let next = textField.superview?.viewWithTag((textField.tag/1000 - 1)*1000) as? UITextField {
            next.text = ""
            next.becomeFirstResponder()
            hpOTPViewDelegate?.hpOTPViewRemoveText(text ?? "", at: next.tag/1000 - 1)
        }
    }
}

protocol HTPBackTextFieldDelegate {
    func textFieldDidDelete(_ textField : UITextField)
}


fileprivate class HTPBackTextField: UITextField {
    
    var HTPBackDelegate : HTPBackTextFieldDelegate?
    weak var hpOTPView : HPOTPView!
    override var text: String? {
        didSet {
            if text?.isEmpty ?? true {
                self.backgroundColor = hpOTPView.backGroundColorTextField
            } else {
                self.backgroundColor = hpOTPView.backGroundColorFilledTextField ?? hpOTPView.backGroundColorTextField
            }
        }
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        HTPBackDelegate?.textFieldDidDelete(self)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(UIResponderStandardEditActions.copy(_:)) ||
//            action == #selector(UIResponderStandardEditActions.cut(_:)) ||
//            action == #selector(UIResponderStandardEditActions.select(_:)) ||
//            action == #selector(UIResponderStandardEditActions.selectAll(_:)) ||
//            action == #selector(UIResponderStandardEditActions.delete(_:)) {
//
//            return false
//        }
//        return super.canPerformAction(action, withSender: sender)
        return false
    }
    
    override func becomeFirstResponder() -> Bool {
        addSelectedBorderColor()
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        addUnselectedBorderColor()
        return super.resignFirstResponder()
    }
    
    fileprivate func addSelectedBorderColor() {
        if let selectedBorderColor = hpOTPView.selectedBorderColorTextField {
            if hpOTPView.isBottomLineTextField {
                addBottomLine(selectedBorderColor, width: hpOTPView.selectedBorderWidthTextField)
            }  else {
                layer.borderColor = selectedBorderColor.cgColor
                layer.borderWidth = hpOTPView.selectedBorderWidthTextField
            }
        } else {
            if hpOTPView.isBottomLineTextField {
                removePreviouslyAddedLayer(name: "bottomBorderLayer")
            }  else {
                layer.borderColor = nil
                layer.borderWidth = 0
            }
        }
    }
    
    fileprivate func addUnselectedBorderColor() {
        if let unselectedBorderColor = hpOTPView.borderColorTextField {
            if hpOTPView.isBottomLineTextField {
                addBottomLine(unselectedBorderColor, width: hpOTPView.borderWidthTextField)
            }  else {
                layer.borderColor = unselectedBorderColor.cgColor
                layer.borderWidth = hpOTPView.borderWidthTextField
            }
        }  else {
            if hpOTPView.isBottomLineTextField {
                removePreviouslyAddedLayer(name: "bottomBorderLayer")
            }  else {
                layer.borderColor = nil
                layer.borderWidth = 0
            }
        }
    }
    
    fileprivate func addBottomLine(_ color : UIColor , width : CGFloat) {
        let border = CALayer()
        border.name = "bottomBorderLayer"
        removePreviouslyAddedLayer(name: border.name ?? "")
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.width - width ,width : self.frame.width ,height: width)
        self.layer.addSublayer(border)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: hpOTPView.textEdgeInsets ?? UIEdgeInsets.zero)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: hpOTPView.editingTextEdgeInsets ?? UIEdgeInsets.zero)
    }
    
    fileprivate func removePreviouslyAddedLayer(name : String) {
        if self.layer.sublayers?.count ?? 0 > 0 {
            self.layer.sublayers?.forEach {
                if $0.name == name {
                    $0.removeFromSuperlayer()
                }
            }
        }
    }
}


fileprivate extension String {
    subscript(_ i: Int) -> String {
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start ..< end])
    }
    
    subscript (r: CountableClosedRange<Int>) -> String {
        let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return String(self[startIndex...endIndex])
    }
}
