//
//  CarsTableViewController.swift
//  Carangas
//
//  Created by Eric Brito on 21/10/17.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class CarsTableViewController: UITableViewController {
    
    var cars: [Car] = []
    
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(named: "main")
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Carregando dados do servidor..."
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    
    @objc func loadData() {
        
        RESTAlamofire.loadCars(onComplete: { (cars) in
            
            self.cars = cars
                        
            // precisa recarregar a tableview usando a main UI thread
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
            
            
        }) { (error) in
            
            var response: String = ""
            
            switch error {
            case .invalidJSON:
                response = "invalidJSON"
            case .noData:
                response = "noData"
            case .noResponse:
                response = "noResponse"
            case .url:
                response = "JSON inválido"
            case .taskError(let error):
                response = "\(error.localizedDescription)"
            case .responseStatusCode(let code):
                if code != 200 {
                    response = "Algum problema com o servidor. :( \nError:\(code)"
                }
            }
            
            // TODO substituir por um objeto Alerta para exibir para o usuario
            print(response)
            
            DispatchQueue.main.async {
                
                self.refreshControl?.endRefreshing()
                
                if response.isEmpty == false {
                    self.label.text = "Ocorreu um erro: \n\n\(response)"
                } else {
                    self.label.text = "Ocorreu um erro desconhecido."
                }
            }
            
            
        }
        
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if cars.count == 0 {
            // mostrar mensagem padrao
            self.tableView.backgroundView = self.label
        } else {
            self.label.text = ""
        }
        
        return cars.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        let car = cars[indexPath.row]
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = car.brand
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
          
            // 1 - Código para remover considerando os CUIDADOS mencionados acima:
            let car = cars[indexPath.row]
            
            
            RESTAlamofire.delete(car: car, onComplete: { (success) in
            //RESTA.delete(car: car) { (success) in
                if success {
                    
                    // ATENCAO nao esquecer disso
                    self.cars.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        // Delete the row from the data source
                        tableView.deleteRows(at: [indexPath], with: .fade)
                   
                    }
                } else {
                    // TODO colocar um alerta de erro aqui
                    print("- colocar um alerta de erro aqui -")
                }
            }){ (error) in
                // TODO - mostrar uma alerto porque ocorreu um erro aqui
                //AddEditViewController.showAlert(withTitle: "Cadastrar", withMessage: "Servidor não conseguiu deletare o Carro.")
            }
            
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewSegue" {
            let vc = segue.destination as? CarViewController
            vc?.car = cars[tableView.indexPathForSelectedRow!.row]
        }
    }
    
    
}
