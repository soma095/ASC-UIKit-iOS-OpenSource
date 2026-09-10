//
//  AmityFeedHeaderTableViewCell.swift
//  AmityUIKit
//
//  Created by Nontapat Siengsanor on 21/10/2563 BE.
//  Copyright © 2563 Amity. All rights reserved.
//

import UIKit

class AmityFeedHeaderTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = AmityColorSet.backgroundColor
    }
    
    func set(headerView: UIView?) {
        guard let headerView = headerView else { return }

        // Portal App Banners: this is called from `cellForRowAt`, so it runs again on every
        // reconfiguration — and the caller hands back the SAME retained view every time (the
        // banner's UIHostingController view). Re-adding it unguarded piled up a duplicate set of
        // the four constraints below on each pass, and moving it between reused cells left the
        // PREVIOUS cell's constraints pointing at a contentView it no longer descends from, which
        // UIKit drops. The result is an ambiguous layout: the header still draws, but its frame is
        // wrong, and hit-testing clips to the superview's bounds — so the banner rendered normally
        // and never received a tap. How many reconfigurations happen depends on screen height and
        // scrolling, which is why it reproduced on device and not in the simulator.
        //
        // Already installed here: nothing to do (re-activating would duplicate).
        guard headerView.superview !== contentView else { return }
        // Moving in from another cell: `removeFromSuperview` also drops the constraints that
        // superview held referencing this view, so the old cell's set cannot linger.
        headerView.removeFromSuperview()

        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
}
