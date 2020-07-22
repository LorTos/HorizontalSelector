//
//  HorizontalSelectorView.swift
//  HorizontalSelector
//
//  Created by Lorenzo Toscani De Col on 19/07/2020.
//

import UIKit

public protocol HorizontalSelectorViewDelegate: class {
	func selector(_ selector: HorizontalSelectorView, didSelectIndex index: Int, with name: String)
}

public class HorizontalSelectorView: UIView {
	private enum SizeState {
		case expanded, collapsed
	}
	private struct State {
		var size: SizeState = .expanded
		var selectedIndex: Int?
		var options: [String] = []
	}
	
	private let animationDuration: TimeInterval = 0.32
	private let stackPadding: CGFloat = 30
	
	private var _font: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold) {
		didSet {
			if !buttons.isEmpty {
				buttons.forEach { $0.titleLabel?.font = _font }
			}
		}
	}
	public var font: UIFont {
		get { _font }
		set { _font = newValue }
	}
	
	private var _isCollapsible = false
	public var isCollapsible: Bool {
		get { _isCollapsible }
		set {
			_isCollapsible = newValue
			if _isCollapsible {
				collapse()
			}
		}
	}
	
	private var _actionString: String?
	public var actionString: String? {
		get { _actionString }
		set { _actionString = newValue }
	}
	
	private var _actionImage: UIImage?
	public var actionImage: UIImage? {
		get { _actionImage }
		set { _actionImage = newValue }
	}
	
	private var hasSelection: Bool {
		state.selectedIndex != nil
	}
	
	public override var tintColor: UIColor! {
		didSet {
			if !buttons.isEmpty {
				buttons.forEach {
					$0.setTitleColor(tintColor, for: .selected)
					$0.setTitleColor(tintColor.withAlphaComponent(0.7), for: .normal)
					$0.tintColor = tintColor
				}
			}
		}
	}
	
	// NOTE:
	// The HorizontalSelector will handle height and horziontal distribution constraints,
	// the constraints that determine the vertical position of the view should be handled by the user.
	private var expandedWidthPercent: CGFloat? {
		guard let superview = superview else { return nil }
		return (superview.bounds.width - (horizontalPadding * 2)) / superview.bounds.width
	}
	private lazy var expandedWidthConstraint: NSLayoutConstraint? = {
		guard let superview = superview, let percent = expandedWidthPercent else {
			return nil
		}
		return widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: percent)
	}()
	private var collapsedWidthPercent: CGFloat = 0.35
	private lazy var collapsedWidthConstraint: NSLayoutConstraint? = {
		guard let superview = superview else {
			return nil
		}
		return widthAnchor.constraint(greaterThanOrEqualTo: superview.widthAnchor, multiplier: collapsedWidthPercent)
	}()
	private var _horizontalPadding: CGFloat = 20
	var horizontalPadding: CGFloat {
		get { _horizontalPadding }
		set { _horizontalPadding = newValue }
	}
	private var _height: CGFloat = 54
	var height: CGFloat {
		get { _height }
		set { _height = newValue }
	}
	
	// MARK: State & Delegate
	private var state = State()
	weak var delegate: HorizontalSelectorViewDelegate?
	
	// MARK: Subviews
	private lazy var buttonStack: UIStackView = {
		let stack = UIStackView(frame: .zero)
		stack.alignment = .fill
		stack.distribution = .equalSpacing
		stack.axis = .horizontal
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()
	private var buttons = [UIButton]()
	
	// MARK: Init
	public init(with options: [String], initialSelection: Int? = nil) {
		super.init(frame: .zero)
		commonInit()
		setup(with: options, initialSelection: initialSelection)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	private func commonInit() {
		translatesAutoresizingMaskIntoConstraints = false
		
		backgroundColor = .black
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.2
		layer.shadowOffset = CGSize(width: 0, height: 1)
		layer.shadowRadius = 6
		
		addSubview(buttonStack)
		buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: stackPadding).isActive = true
		buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -stackPadding).isActive = true
		buttonStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
		buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
	
	public override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		guard let superview = superview else { return }
		centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
		expandedWidthConstraint?.isActive = !isCollapsible
		collapsedWidthConstraint?.isActive = isCollapsible
		heightAnchor.constraint(equalToConstant: _height).isActive = true
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.height / 2
	}
	
	// MARK: Setup
	public func setup(with options: [String], initialSelection: Int? = nil) {
		state.options = options
		state.selectedIndex = initialSelection
		setup()
	}
	private func setup() {
		if !buttons.isEmpty {
			reset()
		}
		addButtons()
		
		guard let selectedIndex = state.selectedIndex, selectedIndex < buttons.count else {
			collapse()
			return
		}
		selected(buttons[selectedIndex])
	}
	
	private func reset() {
		buttons.forEach { $0.removeTarget(self, action: #selector(selected), for: .touchUpInside) }
		buttons.forEach {
			buttonStack.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}
		buttons = []
	}
	
	private func addButtons() {
		let newButtons = state.options.map { button(with: $0) }
		buttons = newButtons
		buttons.forEach {
			buttonStack.addArrangedSubview($0)
		}
	}
	
	// MARK: Button & Target
	private func button(with title: String) -> UIButton {
		let button = UIButton(type: .custom)
		button.setTitle(title, for: .normal)
		button.setTitleColor(tintColor, for: .selected)
		button.setTitleColor(tintColor.withAlphaComponent(0.7), for: .normal)
		button.titleLabel?.font = font
		button.tintColor = tintColor
		button.semanticContentAttribute = .forceRightToLeft
		button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
		button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		button.addTarget(self, action: #selector(selected), for: .touchUpInside)
		return button
	}
	
	@objc private func selected(_ button: UIButton) {
		guard let buttonIndex = buttons.firstIndex(of: button) else { return }
		
		switch state.size {
		case .expanded:
			if let oldIndex = state.selectedIndex {
				buttons[oldIndex].isSelected = false
			}
			button.isSelected = true
			state.selectedIndex = buttonIndex
			delegate?.selector(self, didSelectIndex: buttonIndex, with: button.title(for: .normal) ?? "")
		case .collapsed:
			if let oldIndex = state.selectedIndex {
				buttons[oldIndex].isSelected = true
			}
		}
		
		guard isCollapsible else { return }
		
		let newSize: SizeState = state.size == .collapsed ? .expanded : .collapsed
		switch newSize {
		case .expanded:
			expand() {
				self.state.size = newSize
			}
		case .collapsed:
			collapse() {
				self.state.size = newSize
			}
		}
	}
	
	public func collapse(completion: (() -> Void)? = nil) {
		guard isCollapsible else { return }
		self.state.size = .collapsed
		
		let selected = self.state.selectedIndex ?? 0
		UIView.animate(withDuration: animationDuration * 0.6, animations: {
			self.buttons.forEach {
				let isSelectedButton = $0 == self.buttons[selected]
				if isSelectedButton {
					$0.alpha = 1
				} else {
					$0.alpha = 0
				}
			}
		}) { _ in
			self.buttons.forEach {
				let isSelected = $0 == self.buttons[selected]
				if isSelected {
					if !self.hasSelection, let cta = self.actionString {
						$0.setTitle(cta, for: .normal)
					}
					$0.setImage(self._actionImage, for: .normal)
				}
				$0.isHidden = !isSelected
			}
			
			self.expandedWidthConstraint?.isActive = false
			self.collapsedWidthConstraint?.isActive = true
			
			UIView.animate(withDuration: self.animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
				self.layoutIfNeeded()
			}) { _ in
				completion?()
			}
			
		}
	}
	
	public func expand(completion: (() -> Void)? = nil) {
		self.state.size = .expanded
		
		UIView.animate(withDuration: animationDuration, animations: {
			self.buttons.enumerated().forEach {
				$0.element.alpha = 1
				$0.element.isHidden = false
				$0.element.setImage(nil, for: .normal)
				if let _ = self.actionString {
					$0.element.setTitle(self.state.options[$0.offset], for: .normal)
				}
			}
		})
		expandedWidthConstraint?.isActive = true
		collapsedWidthConstraint?.isActive = false
		UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
			self.layoutIfNeeded()
		}) { _ in
			completion?()
		}
	}
}
