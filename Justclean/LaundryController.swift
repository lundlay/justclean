//
//  LaundryController.swift
//  Justclean
//
//  Created by Oleg Lavronov on 27.07.2022.
//

import UIKit
import CoreData

class LaundryController: UIViewController {
    
    var laundry: Laundry?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ItemTableCell.self, forCellReuseIdentifier: ItemTableCell.className)
        return tableView
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Item> = {
        let context = CoreData.shared.mainContext
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "laundryID = %@", laundry?.laundryID ?? "")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectID", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        return label
    }()
    

    let badgeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 22, y: -05, width: 20, height: 20))
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.textColor = .white
        label.font = label.font.withSize(12)
        label.backgroundColor = .systemRed
        return label
    }()

    lazy var rightBarButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        button.setBackgroundImage(UIImage(systemName: "cart"), for: .normal)
        button.addTarget(self, action: #selector(actionAdd), for: .touchUpInside)
        button.addSubview(badgeLabel)
        return button
    }()


    convenience init(_ laundry: Laundry?)  {
        self.init(nibName: nil, bundle: nil)
        self.laundry = laundry
        imageView.download(from: laundry?.photo)
        nameLabel.text = laundry?.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

        view.addSubview(tableView)
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let bindings = ["imageView": imageView, "nameLabel": nameLabel]
        
        let margins = view.layoutMarginsGuide
        var constraints = [
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: margins.centerYAnchor),
            tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-|",
                                                      options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil,
                                                      views: bindings)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[nameLabel]-|",
                                                      options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil,
                                                      views: bindings)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imageView(200)]-20-[nameLabel]",
                                                      options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil,
                                                      views: bindings)

        NSLayoutConstraint.activate(constraints)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        try? fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    @objc
    func actionAdd() {
        
    }
    
}

// MARK: Data Source
extension LaundryController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sum = laundry?.items.map({$0.qty}).reduce(0, +) ?? 0
        badgeLabel.text = String(describing: sum)
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableCell.className, for: indexPath)
        switch cell {
        case let cell as ItemTableCell:
            cell.with(item)
        default:
            break
        }
        return cell
    }
    
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

// MARK: Table Delegate
extension LaundryController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = fetchedResultsController.object(at: indexPath)
        item.qty += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)  {
            
            let label = UILabel()
            label.textColor = .systemBackground
            label.backgroundColor = .systemRed
            label.textAlignment = .center
            
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            label.text = formatter.string(from: item.price as NSNumber)

            let rect = tableView.rectForRow(at: indexPath)
            let viewRect = tableView.convert(rect, to: self.view)
            
            label.frame = viewRect
            label.layer.cornerRadius = 20 * 0.5
            label.layer.masksToBounds = true

            self.view.addSubview(label)
            
            let cartRect = self.badgeLabel.superview?.convert(self.badgeLabel.frame, to: nil) ?? .zero
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
                label.frame = CGRect(x: cartRect.origin.x, y: cartRect.origin.y, width: 20, height: 20)
                label.layer.cornerRadius = 20 * 0.5
            } completion: { finished in
                label.removeFromSuperview()
            }

        }

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let item = self.fetchedResultsController.object(at: indexPath)
        let favoriteAction = UIContextualAction(style: .normal, title: nil) { (_, _, _) in
            self.tableView.isEditing = false
            if item.qty > 0 {
                item.qty -= 1
                try? item.managedObjectContext?.save()
            }
        }
        favoriteAction.backgroundColor = .systemRed
        favoriteAction.image = UIImage(systemName: "cart.badge.minus")
        
        let configuration = UISwipeActionsConfiguration(actions: [favoriteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

}


// MARK: CoreData
extension LaundryController: NSFetchedResultsControllerDelegate {
 
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


// MARK: Cells
class ItemTableCell: UITableViewCell {
    
    let valueLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        label.textAlignment = .right
        label.textColor = .label
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryView = valueLabel
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func with(_ item: Item) {
        textLabel?.text = item.name
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        detailTextLabel?.text = formatter.string(from: item.price as NSNumber)
        valueLabel.text = String(describing: item.qty)
    }
}

extension UIBarButtonItem {

    var frame: CGRect? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view.frame
    }

    var view: UIView? {
        return self.value(forKey: "view") as? UIView
//        guard let view = self.value(forKey: "view") as? UIView else {
//            return nil
//        }
//        return view.frame
    }

}
