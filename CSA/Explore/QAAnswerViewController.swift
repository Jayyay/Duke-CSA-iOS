//
//  QAAnswerViewController.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/27/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAAnswerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var answer: QAPost!
    let ReuseID_QAAnswer = "QAAnswerCell"

    @IBOutlet weak var tableView: UITableView!
    
    var selectedRs: Rendezvous!
    var kbInput: KeyboardInputView!
    var scrollToY: CGFloat = 0
    var replyToUser: PFUser?
    var replies: [RsReply] = []
    var tableRefresher: UIRefreshControl!
    var queryCompletionCounter: Int = 0
    
    var postConnectSuccess = false
    var postAllowed = true
    let timeoutInSec: NSTimeInterval = 5.0
    
    var lineOfText = 0
    var lastHeight = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answer = AppData.QAData.selectedQAAnswer
        
        initUI()
    }
    
    func initUI() {
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        let nib = UINib(nibName: "QAAnswerCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_QAAnswer)
        
        tableRefresher = UIRefreshControl()
        //tableRefresher.attributedTitle = NSAttributedString(string: "Refreshing")
        tableRefresher.addTarget(self, action: #selector(QAViewController.QARefreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(tableRefresher)
    }
    
    // MARK: tableview delegate and data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_QAAnswer, forIndexPath: indexPath) as! QAAnswerCell
        cell.initWithPost(answer, fromVC: self, fromTableView: tableView, forIndexPath: indexPath)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
