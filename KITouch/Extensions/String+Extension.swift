//
//  String+Extension.swift
//  KITouch
//
//  Created by Роман Вертячих on 26.06.2025.
//
import Foundation

extension String {
    func localized() -> String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}
