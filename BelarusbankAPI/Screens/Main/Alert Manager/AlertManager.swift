//
//  AlertControllers.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 22.01.23.
//

import UIKit

protocol AlertControllerDelegate: AnyObject {
    func needRepeatRequest()
}

final class AlertManager {

    weak var delegate: AlertControllerDelegate?

    func createErrorConnectionAlert(_ errorElements: [ErrorForElement]) -> UIAlertController {
        var message = ""
        errorElements.forEach { (error, type) in
            message += "\(type.elementName): \(error.localizedDescription)\n"
        }
        let alertController = UIAlertController(title: "Не удалось обновить элементы",
                                                message: message,
                                                preferredStyle: .alert)
        let repeatAction = UIAlertAction(title: "Повторить ещё раз", style: .default) { [weak self] _ in
            self?.delegate?.needRepeatRequest()
        }
        let canselAction = UIAlertAction(title: "Закрыть", style: .cancel)

        alertController.addAction(repeatAction)
        alertController.addAction(canselAction)

        return alertController
    }

    func createNoInternetAlert() -> UIAlertController {
        let alertController = UIAlertController(title: "Отсутствует интернет соединение",
                                                message: "Приложение не обновит данные без доступа к интернету",
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .cancel)
        alertController.addAction(action)

        return alertController
    }

    func createDeniedAccessAlert() -> UIAlertController {
        let message = "Без доступа невозможно строить маршруты, перейдите в настройки служб геолокации"
        let alertController = UIAlertController(title: "Доступ к геолокации запрещён",
                                                message: message,
                                                preferredStyle: .alert)
        let optionAction = UIAlertAction(title: "Настройки", style: .default) { _ in
            guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingUrl) {
                UIApplication.shared.open(settingUrl)
            }
        }
        let canselAction = UIAlertAction(title: "Отмена", style: .cancel)

        alertController.addAction(optionAction)
        alertController.addAction(canselAction)

        return alertController
    }
}
