//
//  ChooseTableVC.swift
//  IdCard
//
//  Created by XiangHao on 1/5/24.
//

import UIKit
import ExpandableTableViewController

class ChooseTableVC: ExpandableTableViewController, ExpandableTableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.expandableTableView.expandableDelegate = self
        self.expandableTableView.register(UINib(nibName: "ProgTitleTVC", bundle: nil), forCellReuseIdentifier: "ProgTitleTVC")
        self.expandableTableView.register(UINib(nibName: "ProgContentTVC", bundle: nil), forCellReuseIdentifier: "ProgContentTVC")
    }

    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> UITableViewCell {
        let cell = expandableTableView.dequeueReusableCellWithIdentifier("ProgTitleTVC", forIndexPath: expandableIndexPath) as! ProgTitleTVC
        cell.titleLb.text = "Row " + String(expandableIndexPath.row)
        return cell
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> CGFloat {
        return 44
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, estimatedHeightForRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> CGFloat {
        return 44
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) {
        
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfSubRowsInRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> Int {
        return 1
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, subCellForRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> UITableViewCell {
        let cell = expandableTableView.dequeueReusableCellWithIdentifier("ProgContentTVC", forIndexPath: expandableIndexPath) as! ProgContentTVC
        return cell
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForSubRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> CGFloat {
        return 180
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, estimatedHeightForSubRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> CGFloat {
        return 180
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectSubRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) {
        
    }

}
