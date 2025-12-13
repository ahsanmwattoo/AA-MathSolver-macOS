//
//  MathTopicsViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import Cocoa

class MathTopicsViewController: BaseViewController {

    static var identifier = "MathTopicsViewController"
    @IBOutlet weak var topicsCollectionView: NSCollectionView!
    @IBOutlet weak var titleLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicsCollectionView.delegate = self
        topicsCollectionView.dataSource = self
        topicsCollectionView.isSelectable = true
        topicsCollectionView.allowsMultipleSelection = false
        let nib = NSNib(nibNamed: "MathTopicsCollectionViewCell", bundle: nil)
        topicsCollectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier("MathTopicsCollectionViewCell"))

    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        topicsCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            titleLabel.stringValue = "Master Math from Basics to Advanced!".localized()
        }
    }
}

extension MathTopicsViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return MathTopics.mathTopics.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = topicsCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MathTopicsCollectionViewCell"), for: indexPath) as! MathTopicsCollectionViewCell
        let topics = MathTopics.mathTopics[indexPath.item]
        cell.configure(with: topics)
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let selectedIndexPath = indexPaths.first!
        collectionView.deselectItems(at: indexPaths)
        let topics = MathTopics.mathTopics[selectedIndexPath.item]
        let topicVC = TopicViewController(nibName: "TopicViewController", bundle: nil)
        topicVC.titleText = topics.title.localized()
        topicVC.image = topics.image
        topicVC.subtitle = topics.subtitle.localized()
        topicVC.placeholder = topics.placeholder.localized()
        addChildToNavigation(topicVC)
    }
}

extension MathTopicsViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let baseWidth: CGFloat = 217
        let spacing: CGFloat = 11
        
        let availableWidth = collectionView.bounds.width
        var columns = Int((availableWidth + spacing) / (baseWidth + spacing))
        columns = max(columns, 1)
        
        let totalSpacing = CGFloat(columns - 1) * spacing
        let dynamicWidth = (availableWidth - totalSpacing) / CGFloat(columns)
        
        return CGSize(width: dynamicWidth, height: 133)
    }

    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
}
