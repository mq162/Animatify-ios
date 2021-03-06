//
//  HomeViewController.swift
//  Animatify
//
//  Created by Shubham Singh on 14/06/20.
//  Copyright © 2020 Shubham Singh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController{
    
    override class func description() -> String {
        return "HomeViewController"
    }
    
    // MARK:- outlets for the viewController
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var effectsCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- variables for the viewController
    var containerToggled: Bool = false {
        didSet {
            if (containerToggled) {
                self.containerView.roundCorners(cornerRadius: 20)
            } else {
                self.containerView.roundCorners(cornerRadius: 42)
            }
        }
    }
    
    // hardcoding the tableView data for now
    var effects: [Effects] = [Effects(action: .pulse, title: "Pulse Effect", description: "Pulse effect that can be applied to different views and buttons. Color, size, and duration can be set accordingly.", instructions: ["The effect is created with CALayer, applied to the layer of the view.","For a circular pulse, turn your view into a circle and pass the radius as 2.", "You can also modify animation duration to generate another variety of pulse."], gradientColor1: UIColor(hex: "c33764"), gradientColor2: UIColor(hex: "1d2671")), Effects(action: .shimmer, title: "Shimmer Effect", description: "Shimmer Effect is an unobtrusive loading indicator that provides an engaging way to show the loading.", instructions: ["The effect is created with CAGradientLayer, applied to the layer of the view.", "You can modify the animation duration to change the pace of the shimmer."], gradientColor1: UIColor(hex: "c33764"), gradientColor2: UIColor(hex: "1d2671"))]
    
    // MARK:- lifecycle methods for the viewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.effects.append(contentsOf: [Effects](repeatElement(Effects(action: .none, title: "Coming soon", description: "", instructions: [], gradientColor1: UIColor(named: "background")!, gradientColor2: UIColor(named: "alternateBackground")!), count: 4)))
        
        // registering the collectionView
        self.effectsCollectionView.delegate = self
        self.effectsCollectionView.dataSource = self
        self.effectsCollectionView.register(UINib(nibName: EffectCollectionViewCell.description(), bundle: nil), forCellWithReuseIdentifier: EffectCollectionViewCell.description())
        self.view.bringSubviewToFront(containerView)
        
        // registering the tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: TutorialTableViewCell.description(), bundle: nil), forCellReuseIdentifier: TutorialTableViewCell.description())
        
        self.setupViews()
        self.drawLogo()
    }
    
    // MARK:- outlets for the viewController
    @IBAction func expandButtonPressed(_ sender: Any) {
        ViewAnimationFactory.makeEaseInOutAnimation(duration: 0.75, delay: 0) {
            self.expandButton.transform = self.expandButton.transform.rotated(by: +CGFloat.pi + 0.00000001)
            var containerViewTransform = CGAffineTransform.identity
            containerViewTransform = containerViewTransform.translatedBy(x: 0, y: self.view.frame.height - self.containerView.frame.origin.y - 100)
            self.containerView.transform = containerViewTransform
            self.containerToggled = !self.containerToggled
        }
    }
    
    // MARK:- utility functions for the viewController
    func setupViews() {
        self.containerView.roundCorners(cornerRadius: 42)
        self.logoView.backgroundColor = UIColor.clear
        
        // set the section to collapsed
        self.expandButton.transform = self.expandButton.transform.rotated(by: +CGFloat.pi + 0.00000001)
        var containerViewTransform = CGAffineTransform.identity
        containerViewTransform = containerViewTransform.translatedBy(x: 0, y: self.view.frame.height - self.containerView.frame.origin.y - 100)
        self.containerView.transform = containerViewTransform
        self.containerToggled = !self.containerToggled
        
        
    }
    
    func drawLogo(){
        guard let accentColor = UIColor(named: "accentColor") else { return }
        let logoLayer = LogoLayer(for: logoView, scale: 1.1, duration: 0, lineWidth: 4, trackColor: accentColor, glideColor: UIColor.clear, strokeColor: UIColor.white)
        self.view.layer.insertSublayer(logoLayer, below: self.logoView.layer)
    }
}

// MARK:- Extension for CollectionView
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EffectCollectionViewCell.description(), for: indexPath) as? EffectCollectionViewCell {
            cell.setupCell(effect: effects[indexPath.item])
            return cell
        }
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 2.5
        let collectionViewWidth = collectionView.bounds.width
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let adjustedWidth = (collectionViewWidth * 1.225) - (flowLayout.minimumLineSpacing * (columns - 1))
        let width = floor(adjustedWidth / columns)
        return CGSize(width: width, height: EffectCollectionViewCell().collectionViewHeight)
    }
    
    func  collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let effectDetailsVC = self.storyboard?.instantiateViewController(identifier: EffectDetailsViewController.description()) as? EffectDetailsViewController else { return }
        let selectedEffect = self.effects[indexPath.item]
        if (selectedEffect.action != .none){
            effectDetailsVC.effect = selectedEffect
            self.navigationController?.pushViewController(effectDetailsVC, animated: true)
        }
    }
}

// MARK:- Extension for TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TutorialTableViewCell().tableViewHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: TutorialTableViewCell.description(), for: indexPath) as? TutorialTableViewCell {
            return cell
        }
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            guard let tutorialVC = UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: TableAnimationViewController.description()) as? TableAnimationViewController else { return }
            self.present(tutorialVC, animated: true)
        }
    }
}
