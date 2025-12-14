//
//  MathFormulasViewController.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 26/11/2025.
//

import Cocoa

struct MathSection {
    let topic: String
    let formulas: [Formula]
    var isExpanded: Bool = false
}

class MathFormulasViewController: BaseViewController {
    
    static var identifier = "MathFormulasViewController"
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var titleLabel: NSTextField!
    
    private var expandedIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.hideScrollers()
        tableView.usesAutomaticRowHeights = true
        tableView.intercellSpacing = NSSize(width: 0, height: 16)
        tableView.selectionHighlightStyle = .none
        let nib = NSNib(nibNamed: "FormulaCell", bundle: nil)
        tableView.register(nib!, forIdentifier: NSUserInterfaceItemIdentifier("FormulaCell"))
        tableView.reloadData()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        tableView.reloadData()
    }
    
    override func didChangeLanguage() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            titleLabel.stringValue = "Quick Access to Mathematical Formulas".localized()
        }
    }
    
    @objc func cellClicked(_ sender: NSClickGestureRecognizer) {
        guard let cell = sender.view as? FormulaCell else { return }
        let clickedRow = tableView.row(for: cell)
        
        if expandedIndex == clickedRow {
            expandedIndex = nil
        } else {
            expandedIndex = clickedRow
        }
        
        tableView.reloadData()
        tableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: clickedRow))
        
        // Har row expand hone pe visible ho jayegi
        if expandedIndex == clickedRow {
            DispatchQueue.main.async { [weak tableView] in
                tableView?.scrollRowToVisible(clickedRow)
            }
        }
    }
}

extension MathFormulasViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return MathFormulas.allTopics.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("FormulaCell"), owner: self) as? FormulaCell else {
            return nil
        }
        
        let topicData = MathFormulas.allTopics[row]
        let isExpanded = (expandedIndex == row)
        
        cell.imageIcon?.image = isExpanded ?
            .arrowUp : .arrowDown
        cell.nameLabel.stringValue = topicData.topic.localized()
        cell.nameLabel.font = NSFont.boldSystemFont(ofSize: 16)
        cell.nameLabel.textColor = .labelColor
        
        if isExpanded {
            cell.showFormulas(topicData.formulaNames)
        } else {
            cell.hideFormulas()
        }
        
        cell.gestureRecognizers.removeAll()
        let click = NSClickGestureRecognizer(target: self, action: #selector(cellClicked(_:)))
        cell.addGestureRecognizer(click)
        
        return cell
    }
}
