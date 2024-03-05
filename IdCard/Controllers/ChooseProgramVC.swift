//
//  ChooseProgramVC.swift
//  IdCard
//
//  Created by XiangHao on 1/3/24.
//

import UIKit
import JGProgressHUD

class ChooseProgramVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var hud: JGProgressHUD!
    var data: [Program] = []
    var bLoad: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hud = JGProgressHUD()
        hud.textLabel.text = "Waiting ..."
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ProgContentTVC", bundle: nil), forCellReuseIdentifier: "ProgContentTVC")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !bLoad {
            loadPrograms()
            bLoad = true
        }
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadPrograms() {
        hud.show(in: self.view)
        API.getAllPrograms(token: curUser.token, domain: curUser.domain, onSuccess: { response in
            self.hud.dismiss()
            self.data = response
            self.tableView.reloadData()
        }, onFailed: { err in
            self.hud.dismiss()
            self.showToast(message: err)
        })
    }
}

extension ChooseProgramVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OrderVC") as! OrderVC
        vc.selectedProgram = self.data[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgContentTVC", for: indexPath) as! ProgContentTVC
        let oneProgram = self.data[indexPath.row]
        cell.titleLb.text = oneProgram.program_name
        cell.frontImg.image = oneProgram.card_image_front.toImage()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
