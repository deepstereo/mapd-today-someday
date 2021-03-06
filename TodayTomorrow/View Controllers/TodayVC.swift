//  TodayTomorrow
//
//  Created by Sergii Kozak 300979113
//         and Sergey Sharipov 300300961984
//
//
//  Copyright © 2017 Centennial. All rights reserved.
//

import UIKit
import CoreData

class TodayVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let deselectedGrey = UIColor(displayP3Red: 0.921, green: 0.921, blue: 0.921, alpha: 0.9)
    let todayGreen = UIColor(red: 0.298, green: 0.498, blue: 0, alpha: 1)
    let someDayBlue = UIColor(red: 0.161, green: 0.502, blue: 0.725, alpha: 1)

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tasks: [Task] = []
    var completedTasks: [Task] = []
    
   @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: ---- TableView implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tasks.count == 0 {
            tableView.isHidden = true
            return 0
        } else {
            tableView.isHidden = false
            return tasks.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskCell") as! TodayTaskCell
        cell.todayTaskNameLabel.text = tasks[indexPath.row].taskName
        
        setSelectedCell(cell: cell, checked: tasks[indexPath.row].isCompleted)
        
        if tasks[indexPath.row].taskDescription == "Task description" {
            cell.descriptionLabel.text = ""
        } else {
            cell.descriptionLabel.text = tasks[indexPath.row].taskDescription
        }
        return cell
    }
    
    func setSelectedCell(cell: TodayTaskCell, checked: Bool) {
        if checked {
            cell.setChecked()
        } else{
            cell.setUnchecked()
        }
    }
    
    // Allow table editing
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Add action when table row is swiped
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let moveToSomeDay = UITableViewRowAction(style: .normal, title: "Some day") { (moveToSomeday, indexPath) in
            self.moveTaskToSomeDay(atIndexPath: indexPath)
            }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (deleteAction, indexPath) in
            self.deleteTask(atIndexPath: indexPath)
        }
        moveToSomeDay.backgroundColor = someDayBlue
        return [deleteAction, moveToSomeDay]
    }
    
    
    // Delete row and task from database
    
    func deleteTask(atIndexPath indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        context.delete(task)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        do {
            tasks = try context.fetch(Task.fetchRequest())
        } catch {
            print("fetching failed")
        }
        tableView.reloadData()
    }
    
    
    // Change task to Some day
    
    func moveTaskToSomeDay(atIndexPath indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.dueToday = false
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getData()
        tableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            context.delete(task)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            getData()
            tableView.reloadData()
        }
    }
    
    // MARK: ---- SEGUE - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditTask" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedTask = tasks[indexPath.row]
                let editTaskVC = segue.destination as! EditTaskViewController
                editTaskVC.taskToEdit = selectedTask
            }
        }
    }
    
    
    
    
    // Get data from database
    
    func getData() {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        let sort = NSSortDescriptor(key: #keyPath(Task.isCompleted), ascending: true)
        let predicate = NSPredicate(format: "dueToday == TRUE")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sort]
        do {
            tasks = try context.fetch(fetchRequest)
        } catch {
            print("Cannot fetch")
        }
    }
    
    
    // MARK: ---- Action - Tap on checkbox button
    
    @IBAction func checkBoxCheck(sender: UIButton) {
        let cell = sender.superview?.superview as! TodayTaskCell
        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[(indexPath?.row)!]
        
        task.isCompleted = !task.isCompleted
        setSelectedCell(cell: cell, checked: task.isCompleted)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.tableView.reloadData()
        })
    }
    
    @IBAction func deleteCompletedTasks(_ sender: UIButton) {
        for task in tasks {
            if(task.isCompleted){
                context.delete(task)
            }
        }
        getData()
        tableView.reloadData()
    }
    
    
    
    
    
    // Reload data before view appears
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.unselectedItemTintColor = deselectedGrey
        getData()
        tableView.reloadData()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


