//
//  ViewController.swift
//  PagingKit_Tutorial
//
//  Created by 김동환 on 2021/04/20.
//

import UIKit
import PagingKit

class ViewController: UIViewController {

    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    
    static var viewController: (UIColor) -> UIViewController = { (color) in
           let vc = UIViewController()
            vc.view.backgroundColor = color
            return vc
        }
//
//    var dataSource = [(menuTitle: "test1", vc: viewController(.red)), (menuTitle: "test2", vc: viewController(.blue)), (menuTitle: "test3", vc: viewController(.yellow))]
    
    var dataSource = [(menu: String, content: UIViewController)](){
        didSet{
            menuViewController.reloadData()
            contentViewController.reloadData()
        }
    }
    
    lazy var firstLoad: (() -> Void)? = { [weak self, menuViewController, contentViewController] in menuViewController?.reloadData()
        contentViewController?.reloadData()
        self?.firstLoad = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstLoad?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        menuViewController.register(nib: UINib(nibName: "MenuCell", bundle: nil), forCellWithReuseIdentifier: "MenuCell")
        menuViewController.register(type: TitleLabelMenuViewCell.self, forCellWithReuseIdentifier: "titleLabelMenuCell")
        
//        menuViewController.registerFocusView(nib: UINib(nibName: "FocusView", bundle: nil))
        menuViewController.registerFocusView(view: UnderlineFocusView())
        menuViewController.cellAlignment = .center
        
        dataSource = makeDataSource()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let vc = segue.destination as? PagingMenuViewController {
                menuViewController = vc
                menuViewController.dataSource = self
                menuViewController.delegate = self
            } else if let vc = segue.destination as? PagingContentViewController {
                contentViewController = vc
                contentViewController.dataSource = self
                contentViewController.delegate = self
            }
        }
    
    fileprivate func makeDataSource() -> [(menu: String, content: UIViewController)] {
        let myMenuArray = ["첫번째", "두번째", "세번쨰"]
        
        return myMenuArray.map{
            let title = $0
            
            switch title {
            case "첫번째":
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FirstVC") as! FirstVC
                return (menu: title, content: vc)
            case "두번째":
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SecondVC") as! SecondVC
                return (menu: title, content: vc)
            case "세번째":
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ThirdVC") as! ThirdVC
                return (menu: title, content: vc)
            default:
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FirstVC") as! FirstVC
                return (menu: title, content: vc)
            }
        }
    }

}

extension ViewController: PagingMenuViewControllerDataSource {
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return 100
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
//        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: index) as! MenuCell
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "titleLabelMenuCell", for: index) as! TitleLabelMenuViewCell
        
        cell.titleLabel.text = dataSource[index].menu
       
        return cell
    }
}

extension ViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension ViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
}

extension ViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        // 내용이 스크롤 되면 메뉴를 스크롤 한다.
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}
