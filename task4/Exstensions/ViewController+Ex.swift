//
//  ViewController+Ex.swift
//  task4
//
//  Created by Misha Volkov on 6.01.23.
//

import UIKit

extension ViewController {

    internal func showNoInternetAlert() {
        let alertController = UIAlertController(title: "Отсутствует интернет соединение",
                                                message: "Приложение не работает без доступа к интернету",
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .cancel)

        alertController.addAction(action)

        present(alertController, animated: true)
    }

    internal func showErrorConnectionAlert(error: Error) {
        let alertController = UIAlertController(title: "Ошибка сети",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        let repeatAction = UIAlertAction(title: "Повторить ещё раз", style: .default) { [weak self] _ in
            self?.fetchRequest()
        }
        let canselAction = UIAlertAction(title: "Закрыть", style: .cancel)

        alertController.addAction(repeatAction)
        alertController.addAction(canselAction)

        present(alertController, animated: true)
    }
}
