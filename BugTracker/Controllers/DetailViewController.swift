//
//  DetailViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var descriptionTextView: UITextView!
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
        titleLabel.text = issue?.title
        descriptionTextView.text = issue?.description
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func saveButtonPress(_ sender: Any)
    {
        if let issueId = issue?.id
        {
            DbManager.instance.updateIssue(issueId: issueId, title: titleLabel.text ?? "default title", description: descriptionTextView.text)
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
