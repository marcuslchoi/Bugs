//
//  DetailViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var issue: Issue?
    {
        didSet
        {
            refreshUI()
        }
    }
    
    private func refreshUI()
    {
        loadViewIfNeeded()
        detailDescriptionLabel.text = issue?.title
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //configureView()
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

extension DetailViewController: IssueSelectionDelegate
{
    func onIssueSelected(selectedIssue: Issue) {
        self.issue = selectedIssue
        print("DetailViewController onIssueSelected \(issue?.title)")
    }
}
