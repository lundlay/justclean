//
//  ViewController.swift
//  Justclean
//
//  Created by Oleg Lavronov on 26.07.2022.
//

import UIKit
import CoreData

class HomeController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Laundry> = {
        let context = CoreData.shared.mainContext
        let fetchRequest: NSFetchRequest<Laundry> = Laundry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "favorite", ascending: false),
                                        NSSortDescriptor(key: "updatedAt", ascending: false),
                                        NSSortDescriptor(key: "createdAt", ascending: false),
                                        NSSortDescriptor(key: "objectID", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        return refreshControl
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(imageView)

        tableView.refreshControl = refreshControl
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: margins.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),

            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        imageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(actionLongPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        try? fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    @objc
    func reloadData() {
        API.justclean.refresh(.laundries) { [weak self] error in
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()

            guard self?.display(error: error) == true else {
                return
            }
        }
    }
    
    @objc
    func actionLongPress(_ recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == .began {
            let touchPoint = recognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let item = fetchedResultsController.object(at: indexPath)
                if let photo = item.photo, let url = URL(string: photo) {
                    imageView.download(from: url)
                    
                    UIView.animate(withDuration: 0.3) {
                        self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }
                }
            }
        } else if recognizer.state == .ended || recognizer.state == .cancelled {
            UIView.animate(withDuration: 0.15) {
                self.imageView.transform = CGAffineTransform(scaleX: 0, y: 0)
            }
        }
    }
    
}

// MARK: Data Source
extension HomeController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedResultsController.fetchedObjects?.count ?? 0
        if count == 0 {
            let label = UILabel()
            label.textColor = .label
            label.textAlignment = .center
            label.text = "Please, pull to refresh"
            label.sizeToFit()
            label.center.x = tableView.center.x
            label.center.y = tableView.center.y - label.frame.height
            
            tableView.backgroundView = label
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }

        
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = fetchedResultsController.object(at: indexPath)
        let cell = UITableViewCell()
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = item.name
        return cell
    }
    
}

// MARK: Table Delegate
extension HomeController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = fetchedResultsController.object(at: indexPath)
        let controller = LaundryController(item)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let item = self.fetchedResultsController.object(at: indexPath)
        let favoriteAction = UIContextualAction(style: .normal, title: nil) { (_, _, _) in
            self.tableView.isEditing = false
            item.favorite.toggle()
            try? item.managedObjectContext?.save()
        }
        favoriteAction.backgroundColor = .systemYellow
        favoriteAction.image = UIImage(systemName: item.favorite ? "star.fill" : "star")
        
        let configuration = UISwipeActionsConfiguration(actions: [favoriteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

}


// MARK: CoreData
extension HomeController: NSFetchedResultsControllerDelegate {
 
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections([sectionIndex], with: .fade)
        case .delete:
            tableView.deleteSections([sectionIndex], with: .fade)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .none)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath,
                  indexPath != newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

