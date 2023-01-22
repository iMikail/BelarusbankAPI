//
//  SectionHeaderView.swift
//  task4
//
//  Created by Misha Volkov on 5.01.23.
//

import UIKit

final class SectionHeaderView: UICollectionReusableView {
    static let identifier = "sectionHeader"

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textAlignment = .center

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
