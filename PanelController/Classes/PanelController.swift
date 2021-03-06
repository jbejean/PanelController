//
//  PanelController.swift
//  PanelControllerDemo
//
//  Created by Tanguy Helesbeux on 09/02/2016.
//  Copyright © 2016 HEVA. All rights reserved.
//

import UIKit

public protocol PanelControllerDelegate {
    
    func panelController(_ panelController: PanelController, willChangePanel side: PanelController.PanelSide, toState state: PanelController.PanelState)
    func panelController(_ panelController: PanelController, didChangePanel side: PanelController.PanelSide, toState state: PanelController.PanelState)
    
    func panelController(_ panelController: PanelController, willChangeSizeOfPanel side: PanelController.PanelSide)
    func panelController(_ panelController: PanelController, didChangeSizeOfPanel side: PanelController.PanelSide)
}

public class PanelController: UIViewController {
    
    // MARK: - INITIALIZERS -
    
    public init(centerController: UIViewController?, leftController: UIViewController? = nil, rightController: UIViewController? = nil) {
        super.init(nibName: nil, bundle: nil)
		self.setCenterPanel(with: centerController)
		self.setLeftPanel(with: leftController)
		self.setRightPanel(with: rightController)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PUBLIC -
    
    public enum PanelStyle: Int {
        case above
        case sideBySide
    }
    
    public enum PanelState: Int {
        case opened
        case closed
    }
    
    public enum PanelSide: Int {
        case left
        case right
    }
    
    // MARK: Properties
    
    public private(set) var centerController: UIViewController?
    public private(set) var leftController: UIViewController?
    public private(set) var rightController: UIViewController?
    
    public private(set) var leftPanelState: PanelState = .closed
    public private(set) var rightPanelState: PanelState = .closed
    
    public var leftPanelStyle: PanelStyle = .above     { didSet { self.updateLayout(animated: false) } }
    public var rightPanelStyle: PanelStyle = .above    { didSet { self.updateLayout(animated: false) } }
    
    public var delegate: PanelControllerDelegate?
    
    public var layoutAnimationsDuration: TimeInterval = 0.5
    
    // MARK: API
    
    /**
     
     Applies the given `state` to the panel at the given `side`.
     Animation will start immediately. Any other call to this function will create new animations.
     If you want to change multiple panels at the same time consider using `setPanel(sides:state:)` or `setPanels(changes:)`.
     
     - parameter side: The side of the panel you want to change.
     - parameter state: The state you want to apply to the panel.
     - parameter animated: `Optional`. If `true` will animate with the duration set in `PanelController.layoutAnimationsDuration`.
     
     */
    public func setPanel(side: PanelSide, _ state: PanelState, animated: Bool = false) {
        self.delegate?.panelController(self, willChangePanel: side, toState: state)
        switch side {
        case .left:
            self.leftPanelState  = state
            self.leftController?.beginAppearanceTransition(state == .opened, animated: animated)
        case .right:
            self.rightPanelState = state
            self.rightController?.beginAppearanceTransition(state == .opened, animated: animated)
        }
        
        self.updateLayout(animated: animated) {
            self.delegate?.panelController(self, didChangePanel: side, toState: state)
            switch side {
            case .left: self.leftController?.endAppearanceTransition()
            case .right: self.rightController?.endAppearanceTransition()
            }
        }
        
    }
    
    /**
     
     Applies the given `state` to the panels in `sides`.
     All changes will be grouped and executed in a single animation.
     
     - parameter sides: Array of `PanelSide`, the panels you want to change.
     - parameter state: The state you want to apply to the panels.
     - parameter animated: `Optional`. If `true` will animate with the duration set in `PanelController.layoutAnimationsDuration`.
     
     */
    
    public func setPanels(sides: [PanelSide], _ state: PanelState, animated: Bool = false) {
        for side in sides {
            self.delegate?.panelController(self, willChangePanel: side, toState: state)
            switch side {
            case .left:
                self.leftPanelState  = state
                self.leftController?.beginAppearanceTransition(state == .opened, animated: animated)
            case .right:
                self.rightPanelState = state
                self.rightController?.beginAppearanceTransition(state == .opened, animated: animated)
            }
        }
        self.updateLayout(animated: animated) {
            for side in sides {
                self.delegate?.panelController(self, didChangePanel: side, toState: state)
                switch side {
                case .left: self.leftController?.endAppearanceTransition()
                case .right: self.rightController?.endAppearanceTransition()
                }
            }
        }
    }
    
    /**
     
     Applies a given `change.state` to its `change.side`.
     All changes will be grouped and executed in a single animation.
     
     - parameter changes: Array of `(PanelSide, PanelState)`, list of changed you want to apply.
     - parameter animated: `Optional`. If `true` will animate with the duration set in `PanelController.layoutAnimationsDuration`.
     
     */
    
    public func setPanels(changes: [(side: PanelSide, state: PanelState)], animated: Bool = false) {
        for change in changes {
            self.delegate?.panelController(self, willChangePanel: change.side, toState: change.state)
            switch change.side {
            case .left:
                self.leftPanelState  = change.state
                self.leftController?.beginAppearanceTransition(change.state == .opened, animated: animated)
            case .right:
                self.rightPanelState = change.state
                self.rightController?.beginAppearanceTransition(change.state == .opened, animated: animated)
            }
        }
		self.updateLayout(animated: animated) {
			for change in changes {
				self.delegate?.panelController(self, didChangePanel: change.side, toState: change.state)
				switch change.side {
				case .left: self.leftController?.endAppearanceTransition()
				case .right: self.rightController?.endAppearanceTransition()
				}
			}
		}
    }
    
    // Mark: Panel Setters
    
	public func setCenterPanel(with controller: UIViewController?)   { self._setCenterPanel(with: controller) }
	public func setLeftPanel(with controller: UIViewController?)     { self._setLeftPanel(with: controller)   }
	public func setRightPanel(with controller: UIViewController?)    { self._setRightPanel(with: controller)  }
    
    // MARK: - PRIVATE -
    
    @IBOutlet var centerPanelConstraints: [NSLayoutConstraint]?
    @IBOutlet var leftPanelConstraints: [NSLayoutConstraint]?
    @IBOutlet var rightPanelConstraints: [NSLayoutConstraint]?
    
    @IBOutlet weak var centerPanelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerPanelTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftPanelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftPanelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightPanelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightPanelWidthConstraint: NSLayoutConstraint!
    
    typealias completionBlock = () -> Void
    
    // MARK: Panel setters
    
    private func _setCenterPanel(with controller: UIViewController?) {
		guard let centerController = controller else { return self.remove(controller: self.centerController) }
        guard !centerController.isEqual(self.centerController) else { return }
        
		self.remove(controller: self.centerController)
        self.addChildViewController(centerController)
        centerController.willMove(toParentViewController: self)
        centerController.view.translatesAutoresizingMaskIntoConstraints = false
		self.view.insertSubview(centerController.view, at: 0)
        
        let topConstraint =         NSLayoutConstraint(item: self.view, attribute: .top,         relatedBy: .equal, toItem: centerController.view, attribute: .top,         multiplier: 1.0, constant: 0.0)
        let bottomConstraint =      NSLayoutConstraint(item: self.view, attribute: .bottom,      relatedBy: .equal, toItem: centerController.view, attribute: .bottom,      multiplier: 1.0, constant: 0.0)
        let leadingConstraint =     NSLayoutConstraint(item: self.view, attribute: .leading,     relatedBy: .equal, toItem: centerController.view, attribute: .leading,     multiplier: 1.0, constant: 0.0)
        let trailingConstraint =    NSLayoutConstraint(item: self.view, attribute: .trailing,    relatedBy: .equal, toItem: centerController.view, attribute: .trailing,    multiplier: 1.0, constant: 0.0)
        
        self.centerPanelConstraints = [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]
        self.centerPanelLeadingConstraint = leadingConstraint
        self.centerPanelTrailingConstraint = trailingConstraint
        
        self.view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        
        centerController.didMove(toParentViewController: self)
        self.updateViewConstraints()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.centerController = centerController
    }
    
    private func _setLeftPanel(with controller: UIViewController?) {
		guard let leftController = controller else { return self.remove(controller: self.leftController) }
        guard !leftController.isEqual(self.leftController) else { return }
        
		self.remove(controller: self.leftController)
        self.addChildViewController(leftController)
        leftController.willMove(toParentViewController: self)
        leftController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(leftController.view)
        
		let width = self.width(for: leftController)
        let topConstraint =         NSLayoutConstraint(item: self.view,             attribute: .top,         relatedBy: .equal, toItem: leftController.view, attribute: .top,            multiplier: 1.0, constant: 0.0)
        let bottomConstraint =      NSLayoutConstraint(item: self.view,             attribute: .bottom,      relatedBy: .equal, toItem: leftController.view, attribute: .bottom,         multiplier: 1.0, constant: 0.0)
        let leadingConstraint =     NSLayoutConstraint(item: self.view,             attribute: .leading,     relatedBy: .equal, toItem: leftController.view, attribute: .leading,        multiplier: 1.0, constant: 0.0)
        let widthConstraint =       NSLayoutConstraint(item: leftController.view,   attribute: .width,       relatedBy: .equal, toItem: nil,                 attribute: .notAnAttribute, multiplier: 1.0, constant: width)
        
        self.leftPanelConstraints = [leadingConstraint, topConstraint, bottomConstraint, widthConstraint]
        self.leftPanelLeadingConstraint = leadingConstraint
        self.leftPanelWidthConstraint = widthConstraint
        
        self.view.addConstraints([topConstraint, bottomConstraint, leadingConstraint])
        leftController.view.addConstraint(widthConstraint)
        
        leftController.didMove(toParentViewController: self)
        self.updateViewConstraints()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.leftController = leftController
    }
    
    private func _setRightPanel(with controller: UIViewController?) {
		guard let rightController = controller else { return self.remove(controller: self.rightController) }
        guard !rightController.isEqual(self.rightController) else { return }
        
		self.remove(controller: self.rightController)
        self.addChildViewController(rightController)
        rightController.willMove(toParentViewController: self)
        rightController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(rightController.view)
        
		let width = self.width(for: rightController)
        let topConstraint =         NSLayoutConstraint(item: self.view,             attribute: .top,        relatedBy: .equal, toItem: rightController.view, attribute: .top,               multiplier: 1.0, constant: 0.0)
        let bottomConstraint =      NSLayoutConstraint(item: self.view,             attribute: .bottom,     relatedBy: .equal, toItem: rightController.view, attribute: .bottom,            multiplier: 1.0, constant: 0.0)
        let trailingConstraint =    NSLayoutConstraint(item: self.view,             attribute: .trailing,   relatedBy: .equal, toItem: rightController.view, attribute: .trailing,          multiplier: 1.0, constant: 0.0)
        let widthConstraint =       NSLayoutConstraint(item: rightController.view,  attribute: .width,      relatedBy: .equal, toItem: nil,                  attribute: .notAnAttribute,    multiplier: 1.0, constant: width)
        
        self.rightPanelConstraints = [trailingConstraint, topConstraint, bottomConstraint, widthConstraint]
        self.rightPanelTrailingConstraint = trailingConstraint
        self.rightPanelWidthConstraint = widthConstraint
        
        self.view.addConstraints([topConstraint, bottomConstraint, trailingConstraint])
        rightController.view.addConstraint(widthConstraint)
        
        rightController.didMove(toParentViewController: self)
        self.updateViewConstraints()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.rightController = rightController
    }
    
    // MARK: Child controllers
    
    private func remove(controller: UIViewController!) {
        guard controller != nil else { return }
		controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
		controller.didMove(toParentViewController: nil)
    }
	
	override public func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        guard let controller = container as? UIViewController else { return }
		guard let side = self.side(for: controller) else { return }
        
        self.delegate?.panelController(self, willChangeSizeOfPanel: side)
		self.updateLayout(animated: true) {
            self.delegate?.panelController(self, didChangeSizeOfPanel: side)
        }
    }
    private func side(for controller: UIViewController) -> PanelSide? {
        if controller.isEqual(self.leftController) {
            return .left
        } else if controller.isEqual(self.rightController) {
            return .right
        } else {
            return nil
        }
    }
    
    // MARK: Layout
    
    private func updateLayout(animated: Bool, duration: TimeInterval? = nil, completion: completionBlock? = nil) {
        let finalDuration = duration ?? self.layoutAnimationsDuration
        self.updateViewConstraints()
        guard animated else {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            completion?()
            return
        }
		
		UIView.animate(withDuration: finalDuration, animations: { () -> Void in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }, completion: { finished in
                if finished { completion?() }
        })
    }
    
    override public func updateViewConstraints() {
        
        // Panel left
		let leftWidth = self.width(for: self.leftController)
        let leftOffset = self.leftPanelState == .opened ? 0.0 : leftWidth
        if self.leftPanelLeadingConstraint != nil {
            self.leftPanelLeadingConstraint.constant = leftOffset
            self.leftPanelWidthConstraint.constant = leftWidth
        }
        
        // Panel right
		let rightWidth = self.width(for: self.rightController)
        let rightOffset = self.rightPanelState == .opened ? 0.0 : -rightWidth
        if self.rightPanelTrailingConstraint != nil {
            self.rightPanelTrailingConstraint.constant = rightOffset
            self.rightPanelWidthConstraint.constant = rightWidth
        }
        
        // Center
        if self.centerPanelLeadingConstraint != nil {
            self.centerPanelLeadingConstraint.constant = self.leftPanelStyle == .sideBySide && self.leftPanelState == .opened ? -leftWidth : 0.0
            self.centerPanelTrailingConstraint.constant = self.rightPanelStyle == .sideBySide && self.rightPanelState == .opened  ? rightWidth : 0.0
        }
        
        super.updateViewConstraints()
    }
    
    // MARK: Content sizes
    
	static let defaultPanelWidth: CGFloat = 300.0
    
    private func width(for controller: UIViewController?) -> CGFloat {
        if let width = controller?.preferredContentSize.width, width > 0.0 {
            return width
        }
        return PanelController.defaultPanelWidth
    }
    
}
