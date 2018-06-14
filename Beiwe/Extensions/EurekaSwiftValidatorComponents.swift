//
//  EurekaSwiftValidatorComponents.swift
//  Examples
//
//  Created by Demetrio Filocamo on 12/03/2016.
//  Copyright © 2016 Novaware Ltd. All rights reserved.
//
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Fixes & Modifications by Keary Griffin, RocketFarmStudios

import Eureka
import SwiftValidator
import ObjectiveC

open class _SVFieldCell<T>: _FieldCell<T> where T: Equatable, T: InputTypeInitiable {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    lazy open var validationLabel: UILabel = {
        [unowned self] in
        let validationLabel = UILabel()
        validationLabel.translatesAutoresizingMaskIntoConstraints = false
        validationLabel.font = validationLabel.font.withSize(10.0)
        return validationLabel
        }()

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .sentences
        textField.keyboardType = .default

        self.height = {
            60
        }
        contentView.addSubview(validationLabel)

        let sameLeading: NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: .leading, relatedBy: .equal, toItem: self.validationLabel, attribute: .leading, multiplier: 1, constant: -20)
        let sameTrailing: NSLayoutConstraint = NSLayoutConstraint(item: self.textField, attribute: .trailing, relatedBy: .equal, toItem: self.validationLabel, attribute: .trailing, multiplier: 1, constant: 0)
        let sameBottom: NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .equal, toItem: self.validationLabel, attribute: .bottom, multiplier: 1, constant: 4)
        let all: [NSLayoutConstraint] = [sameLeading, sameTrailing, sameBottom]

        contentView.addConstraints(all)

        validationLabel.textAlignment = NSTextAlignment.right
        validationLabel.adjustsFontSizeToFitWidth = true
        resetField()
    }

    func setRules(_ rules: [Rule]?) {
        self.rules = rules
    }

    override open func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)

        if autoValidation {
            validate()
        }
    }

    // MARK: - Validation management

    func validate() {
        if let v = self.validator {
            // Registering the rules
            if !rulesRegistered {
                v.unregisterField(textField)  //  in case the method has already been called
                if let r = rules {
                    v.registerField(textField, errorLabel: validationLabel, rules: r)
                }
                self.rulesRegistered = true
            }

            self.valid = true

            v.validate({
                (errors) -> Void in
                self.resetField()
                for (field, error) in errors {
                    self.valid = false
                    self.showError(field as! UITextField, error: error)
                }
            })
        } else {
            self.valid = false
        }
    }

    func resetField() {
        validationLabel.isHidden = true
        textField.textColor = UIColor.black
        //textLabel?.textColor = UIColor.blackColor();
    }

    func showError(_ field: UITextField, error: SwiftValidator.ValidationError) {
        // turn the field to red
        field.textColor = errorColor
        /*
        if let ph = field.placeholder {
            let str = NSAttributedString(string: ph, attributes: [NSForegroundColorAttributeName: errorColor])
            field.attributedPlaceholder = str
        }
        */
        //self.textLabel?.textColor = errorColor
        self.validationLabel.textColor = errorColor
        error.errorLabel?.text = error.errorMessage // works if you added labels
        error.errorLabel?.isHidden = false
    }

    var validator: Validator? {
        get {
            if let fvc = formViewController() {
                return fvc.form.validator
            }
            return nil;
        }
    }

    var errorColor: UIColor = UIColor.red
    var autoValidation = true
    var rules: [Rule]? = nil

    fileprivate var rulesRegistered = false
    var valid = false
}


public protocol SVRow {
    var errorColor: UIColor { get set }

    var rules: [Rule]? { get set }

    var autoValidation: Bool { get set }

    var valid: Bool { get }

    func validate();
}

open class _SVTextRow<Cell: _SVFieldCell<String>>: FieldRow<Cell>, SVRow where Cell: BaseCell, Cell: CellType, Cell: TextFieldCell, Cell.Value == String {
    public required init(tag: String?) {
        super.init(tag: tag)
    }

    open var errorColor: UIColor {
        get {
            return self.cell.errorColor
        }
        set {
            self.cell.errorColor = newValue
        }
    }

    open var rules: [Rule]? {
        get {
            return self.cell.rules
        }
        set {
            self.cell.setRules(newValue)
        }
    }

    open var autoValidation: Bool {
        get {
            return self.cell.autoValidation
        }
        set {
            self.cell.autoValidation = newValue
        }
    }

    open var valid: Bool {
        get {
            return self.cell.valid
        }
    }

    open func validate() {
        self.cell.validate()
    }
}

open class SVTextCell: _SVFieldCell<String>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .sentences
        textField.keyboardType = .default
    }
}

open class SVAccountCell: SVTextCell {

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .asciiCapable
    }
}

open class SVPhoneCell: SVTextCell {

    open override func setup() {
        super.setup()
        textField.keyboardType = .phonePad
    }
}

open class SVSimplePhoneCell: SVTextCell {

    open override func setup() {
        super.setup()
        textField.keyboardType = .numberPad
    }
}

open class SVNameCell: SVTextCell {

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.keyboardType = .asciiCapable    }
}

open class SVEmailCell: SVTextCell {

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
    }
}

open class SVPasswordCell: SVTextCell {

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = true
    }
}

open class SVURLCell: SVTextCell {

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .URL    }
}

open class SVZipCodeCell: SVTextCell {

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .allCharacters
        textField.keyboardType = .numbersAndPunctuation
    }
}


extension Form {

    fileprivate struct AssociatedKey {
        static var validator: UInt8 = 0
        static var dataValid: UInt8 = 0
    }

    var validator: Validator {
        get {
            if let validator = objc_getAssociatedObject(self, &AssociatedKey.validator) {
                return validator as! Validator
            } else {
                let v = Validator()
                self.validator = v
                return v
            }
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKey.validator, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var dataValid: Bool {
        get {
            if let dv = objc_getAssociatedObject(self, &AssociatedKey.dataValid) {
                return dv as! Bool
            } else {
                let dv = false
                self.dataValid = dv
                return dv
            }
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKey.dataValid, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func validateAll() -> Bool {
        dataValid = true

        let rows = allRows
        for row in rows {
            if row is SVRow {
                var svRow = (row as! SVRow)
                svRow.validate()
                let rowValid = svRow.valid
                svRow.autoValidation = true // from now on autovalidation is enabled
                if !rowValid && dataValid {
                    dataValid = false
                }
            }
        }
        return dataValid
    }
}

/// A String valued row where the user can enter arbitrary text.

public final class SVTextRow: _SVTextRow<SVTextCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class SVAccountRow: _SVTextRow<SVAccountCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class SVPhoneRow: _SVTextRow<SVPhoneCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class SVSimplePhoneRow: _SVTextRow<SVSimplePhoneCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class SVNameRow: _SVTextRow<SVNameCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class SVEmailRow: _SVTextRow<SVEmailCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class SVPasswordRow: _SVTextRow<SVPasswordCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class SVURLRow: _SVTextRow<SVURLCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class SVZipCodeRow: _SVTextRow<SVZipCodeCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

// TODO add more
