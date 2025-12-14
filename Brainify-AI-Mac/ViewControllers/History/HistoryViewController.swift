//
//  HistoryViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import Cocoa
import Combine

class HistoryViewController: BaseViewController {

    static var identifier = "HistoryViewController"
    
    @IBOutlet weak var tabsCollectionView: NSCollectionView!
    @IBOutlet weak var historyCollectionView: NSCollectionView!
    @IBOutlet weak var startNowLabel: NSTextField!
    @IBOutlet weak var emptyViewLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var emptyView: NSBox!
    
    var chats: [CDMath] = []
    private var selectedItemIndex: Int?
    private var sharingPicker: NSSharingServicePicker?
    private var cancellables = Set<AnyCancellable>()
    private var viewModel = HistoryViewModel()
    
    var menuItems: [String] = []
    var menuIcons: [NSImage?] = []
    
    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "HistoryViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        menuItems = ["All","AI Math","Math Topics"]
//        menuIcons = [nil,.sideBarIcon1, .sideBarIcon2]
        setupCollectionView()
        bindViewmodel()
        updateViews()

    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        viewModel.fetchChats()  // Refresh data every time view appears
        historyCollectionView.reloadData()
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            titleLabel.stringValue = "Keep Track of Activity!".localized()
            emptyViewLabel.stringValue = "No activity yet, let's get started!".localized()
            startNowLabel.stringValue = "Start Now".localized()
        }
    }
    
    func bindViewmodel() {
        viewModel.$chats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snaps in
                self?.historyCollectionView.reloadData()
                self?.emptyView.isHidden = !snaps.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func updateViews() {
        emptyView.isHidden = viewModel.chats.count > 0
    }
    
    func setupCollectionView() {
//        tabsCollectionView.delegate = self
//        tabsCollectionView.dataSource = self
//        tabsCollectionView.hideScrollers()
//        let nib = NSNib(nibNamed: "HistoryTabsCollectionViewCell", bundle: nil)
//        tabsCollectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HistoryTabsCollectionViewCell"))
        historyCollectionView.dataSource = self
        historyCollectionView.delegate = self
        historyCollectionView.isSelectable = true
        historyCollectionView.allowsMultipleSelection = false
        historyCollectionView.hideScrollers()
        historyCollectionView.register(HistoryCollectionViewItem.self, forItemWithIdentifier: HistoryCollectionViewItem.identifier)
//        tabsCollectionView.isSelectable = true
//        tabsCollectionView.allowsMultipleSelection = false
//        tabsCollectionView.selectItem(index: 0, section: 0)
    }
    
    @IBAction func startNowButtonTapped(_ sender: Any) {
        guard let contentVC = view.window?.contentViewController as? ContentViewController else { return }
        contentVC.selectFirstTab()
    }
    
    func openMathResult(for math: CDMath) {
            let resultVC: MathResultViewController
        guard let solutionText = math.solution else {  return }
            if let imageData = math.problemImage, let image = NSImage(data: imageData), image.isValid {
                resultVC = MathResultViewController(problemImage: image, solutionText: solutionText)
            } else {
                resultVC = MathResultViewController(problemText: math.problemText ?? "", solutionText: solutionText)
            }
            addChildToNavigation(resultVC)
        }
}

extension HistoryViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.chats.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
//        if collectionView == tabsCollectionView {
//            let cell = tabsCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: HistoryTabsCollectionViewCell.identifier.rawValue), for: indexPath) as! HistoryTabsCollectionViewCell
//            cell.configure(with: menuItems[indexPath.item].localized(), icon: menuIcons[indexPath.item] ?? NSImage())
//            return cell
//        } else {
            let cell = historyCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: HistoryCollectionViewItem.identifier.rawValue), for: indexPath) as! HistoryCollectionViewItem
            let chat = viewModel.chats[indexPath.item]
        cell.delegate = self
            cell.math = chat  // ← YE BADI CHEEZ THI JO MISSING THI!
            return cell
//    }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
                let chat = viewModel.chats[indexPath.item]
                openMathResult(for: chat)
                collectionView.deselectItems(at: indexPaths)
    }
}

extension HistoryViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView == tabsCollectionView {
//            let title = menuItems[indexPath.item]
//            let textField = NSTextField()
//            textField.font = .systemFont(ofSize: 16, weight: .medium)
//            let textWidth = textField.bestWidth(for: title, height: 40)
//            let spacingAndImageWidth: CGFloat = 45.0
//            let width = textWidth + spacingAndImageWidth
//            return CGSize(width: width, height: 40)
//        } else {
        let baseWidth: CGFloat = 217
        let spacing: CGFloat = 11
        
        let availableWidth = historyCollectionView.bounds.width
        var columns = Int((availableWidth + spacing) / (baseWidth + spacing))
        columns = max(columns, 1)
        
        let totalSpacing = CGFloat(columns - 1) * spacing
        let dynamicWidth = (availableWidth - totalSpacing) / CGFloat(columns)
        
        return CGSize(width: dynamicWidth, height: 130)
        //}
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return /*collectionView == tabsCollectionView ? 22 :*/ 11
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return /*collectionView == tabsCollectionView ? 22 :*/ 11
    }
}

extension HistoryViewController {
    func showDeleteConfirmation(for chat: CDMath) {
        DispatchQueue.main.async {
            
            let alert = NSAlert()
            alert.messageText = "Delete History".localized()
            alert.informativeText = "Are you sure you want to delete this History?".localized()
            alert.alertStyle = .informational
            
            alert.addButton(withTitle: "Delete".localized())
            alert.addButton(withTitle: "Cancel".localized())
            
            let response = alert.runModal()
            
            switch response {
            case .alertFirstButtonReturn:
                self.handleDeleteAction(math: chat)
            case .alertSecondButtonReturn:
                self.dismiss(nil)
            default:
                break
            }
        }
    }

    func handleShareAction(math: CDMath, from sourceView: NSView) {
        guard let text = math.solution else { return }
        
        let sharingPicker = NSSharingServicePicker(items: [text])
        sharingPicker.show(relativeTo: sourceView.bounds, of: sourceView, preferredEdge: .maxX)

    }

    func handleDeleteAction(math: CDMath) {
        showLoading()
        viewModel.deleteChat(math)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.hideLoading()
        }
    }
}

extension HistoryViewController: NSSharingServicePickerDelegate {
    func sharingServicePickerDidDismiss(_ sharingServicePicker: NSSharingServicePicker) {
        self.sharingPicker = nil
    }
}
