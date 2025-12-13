//
//  CalculatorViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 28/11/2025.
//

import Cocoa

class CalculatorViewController: BaseViewController {

    static var identifier = "CalculatorViewController"
    @IBOutlet weak var calculatorCollectionView: NSCollectionView!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    
    
   var isOpenedAsPopUp: Bool = false {
        didSet {
            updateView()
        }
    }
    var calculatorTypes: [String] = []
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatorTypes = ["Basic".localized(), "Calculus".localized(), "Arithmetic".localized()]
      //  setupCollectionView()
        setupCalculators()
     //   calculatorCollectionView.selectItem(index: 0, section: 0)
    }
    
    override func didChangeLanguage() {
        super.didChangeLanguage()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
          ///  calculatorTypes = ["Basic".localized(), "Calculus".localized(), "Arithmetic".localized()]
            titleLabel.stringValue = "Solve, Simplified, Achieve!".localized()
         //   calculatorCollectionView.selectItem(index: selectedIndex, section: 0)
        }
    }
    
    func updateView() {
        if isOpenedAsPopUp {
            setupCalculators()
            titleLabel.isHidden = true
            let basic = tabView.selectedTabViewItem?.viewController as! BasicCalculatorViewController
            basic.isPopupMode = true
            collectionViewTopConstraint.constant = 20
        } else {
            titleLabel.isHidden = false
            setupCalculators()
            
        }
    }
    
//    func setupCollectionView() {
//        calculatorCollectionView.delegate = self
//        calculatorCollectionView.dataSource = self
//        calculatorCollectionView.allowsMultipleSelection = false
//        calculatorCollectionView.isSelectable = true
//        calculatorCollectionView.allowsEmptySelection = false
//        let nib = NSNib(nibNamed: "CalculatorCollectionViewCell", bundle: nil)
//        calculatorCollectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier("CalculatorCollectionViewCell"))
//    }
    
    func setupCalculators() {
        let basicVC = BasicCalculatorViewController(nibName: "BasicCalculatorViewController", bundle: nil)
        let basicTabItem = NSTabViewItem(viewController: basicVC)
        //        let calculusVC = CalculusViewController(nibName: "CalculusViewController", bundle: nil)
        //        let calculusTabItem = NSTabViewItem(viewController: calculusVC)
        //
        //        let arithmeticVC = ArithmeticCalculatorViewController(nibName: "ArithmeticCalculatorViewController", bundle: nil)
        //        let arithmeticTabItem = NSTabViewItem(viewController: arithmeticVC)
        
        
        tabView.addTabViewItem(basicTabItem)
        //        tabView.addTabViewItem(calculusTabItem)
        //        tabView.addTabViewItem(arithmeticTabItem)
        tabView.selectTabViewItem(at: 0)
    }
}

//extension CalculatorViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
//    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
//        return calculatorTypes.count
//    }
//    
//    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
//        let cell = calculatorCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("CalculatorCollectionViewCell"), for: indexPath) as! CalculatorCollectionViewCell
//        cell.titleLabel.stringValue = calculatorTypes[indexPath.item]
//        return cell
//    }
//    
////    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
////        if let selectedIndexPath = indexPaths.first?.item {
////            selectedIndex = selectedIndexPath
////            tabView.selectTabViewItem(at: selectedIndexPath)
////        }
////    }
//}
//
//extension CalculatorViewController: NSCollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
//        return NSSize(width: (collectionView.frame.width - 24) / 3, height: 40)
//    }
//    
//    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 22
//    }
//}
