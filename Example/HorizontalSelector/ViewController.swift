//
//  ViewController.swift
//  HorizontalSelector
//
//  Created by LorTos on 07/19/2020.
//  Copyright (c) 2020 LorTos. All rights reserved.
//

import UIKit
import HorizontalSelector

class ViewController: UIViewController {
	
	private lazy var expandedSelector: HorizontalSelectorView = {
		let selector = HorizontalSelectorView(with: ["option 1", "option 2", "option 3", "option 4"], initialSelection: 0)
		selector.backgroundColor = .black
		selector.tintColor = .white
		return selector
	}()
	
	private lazy var collapsingSelector: HorizontalSelectorView = {
		let selector = HorizontalSelectorView(with: ["option 1", "option2", "option 3"])
		selector.backgroundColor = .black
		selector.tintColor = .white
		selector.isCollapsible = true
		selector.actionString = "Select option"
		if #available(iOS 13.0, *) {
			selector.actionImage = UIImage(systemName: "arrowtriangle.right.fill", compatibleWith: nil)
		}
		return selector
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(expandedSelector)
		expandedSelector.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		
		view.addSubview(collapsingSelector)
		collapsingSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
	}
	
}

