//
//  TableViewExtension.swift
//  ExtensionDemo
//
//  Created by Rajat on 1/14/16.
//  Copyright © 2016 Rajat. All rights reserved.
//

import UIKit

extension UITableView {
    func displayBackgroundText2(text: String, fontStyle: String, fontSize: CGFloat) {
        let lblHoney = UILabel();
        if let headerView = self.tableHeaderView {
        lblHoney.frame = CGRect(x: 0, y: headerView.bounds.size.height, width: self.bounds.size.width, height: self.bounds.size.height - headerView.bounds.size.height)
        } else {
            lblHoney.frame = CGRect(x: 10, y: 0, width: self.bounds.size.width - 20, height: self.bounds.size.height);
        }
        lblHoney.text = text;
        lblHoney.textColor = UIColor.black;
        lblHoney.numberOfLines = 0;
        lblHoney.textAlignment = .center;
        lblHoney.font = UIFont(name: fontStyle, size:fontSize);
        //        lblHoney.sizeToFit();
        
        let backgroundViewHoney = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height));
        backgroundViewHoney.addSubview(lblHoney);
        self.backgroundView = backgroundViewHoney;
    }
    
    func displayBackgroundText(text: String, fontStyle: String) {
        let lblHoney = UILabel();
        
        if let headerView = self.tableHeaderView {
            lblHoney.frame = CGRect(x: 0, y: headerView.bounds.size.height, width: self.bounds.size.width, height: self.bounds.size.height - headerView.bounds.size.height)
        } else {
            lblHoney.frame = CGRect(x: 10, y: 0, width: self.bounds.size.width - 20, height: self.bounds.size.height);
        }
        lblHoney.text = text;
        lblHoney.textColor = UIColor.black;
        lblHoney.numberOfLines = 0;
        lblHoney.textAlignment = .center;
        lblHoney.font = UIFont(name: fontStyle, size:18);
        //        lblHoney.sizeToFit();
        
        let backgroundViewHoney = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height));
        backgroundViewHoney.addSubview(lblHoney);
        self.backgroundView = backgroundViewHoney;
    }
    
    func displayBackgroundText(text: String) {
        let lblHoney = UILabel();
        
        if let headerView = self.tableHeaderView {
            lblHoney.frame = CGRect(x: 0, y: headerView.bounds.size.height, width: self.bounds.size.width, height: self.bounds.size.height - headerView.bounds.size.height)
        } else {
            lblHoney.frame = CGRect(x: 10, y: 0, width: self.bounds.size.width - 20, height: self.bounds.size.height);
        }
        lblHoney.text = text;
        lblHoney.textColor = UIColor.black;
        lblHoney.numberOfLines = 0;
        lblHoney.textAlignment = .center;
        lblHoney.font = UIFont(name: "Palatino-Italic", size:18);
        //lblHoney.sizeToFit();
        
        let backgroundViewHoney = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height));
        backgroundViewHoney.addSubview(lblHoney);
        self.backgroundView = backgroundViewHoney;
    }
    
    
    
    func displayBackgroundImageWithText(text: String? = "No data found", imgName: String? = "cloud", textColor: UIColor? = .black) {
        //View
        var viewBGCenter = UIView()
        if let headerView = self.tableHeaderView {
            viewBGCenter.frame = CGRect(x: 0, y: headerView.bounds.size.height, width: self.bounds.size.width, height: self.bounds.size.height - headerView.bounds.size.height)
        } else {
            viewBGCenter.frame = CGRect(x: 10, y: 0, width: self.bounds.size.width - 20, height: self.bounds.size.height);
        }
        viewBGCenter.backgroundColor = UIColor.clear
        //Image
        let imgView = UIImageView()
        imgView.frame = CGRect( x: viewBGCenter.frame.size.width/2 - 45 , y: 10, width: 90, height: 61)  //  - 45 is a  imgView.width / 2
        imgView.image = UIImage(named: imgName!)
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = UIColor.clear
        //Lable
        let lblText = UILabel()
        lblText.frame = CGRect( x: 10, y: imgView.frame.origin.y + imgView.frame.size.height + 10, width: viewBGCenter.frame.size.width - 20, height: 100)
        
        
        
        lblText.textColor = textColor
        lblText.numberOfLines = 0
        lblText.backgroundColor = UIColor.clear
        lblText.textAlignment = .center
    
        lblText.font = UIFont.systemFont(ofSize: 12)
        let strLableText = text
        let height = self.heightForView(text: strLableText!, font: lblText.font, width: viewBGCenter.frame.size.width - 20 )
        let   heightviewBG = height + imgView.frame.size.height + 30
        
        viewBGCenter = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: heightviewBG));
        //CGRect(x: 0, y: 0, width: 80, height: 80)
        
        
        imgView.frame = CGRect(x : viewBGCenter.frame.size.width/2 - 45 , y:  10, width:  90, height: 61)  //  - 45 is a  imgView.width / 2
        lblText.frame = CGRect( x: 10, y : imgView.frame.origin.y + imgView.frame.size.height + 10, width:   viewBGCenter.frame.size.width - 20, height: height)
        lblText.text = strLableText //Give lblText only on there
        let backgroundViewHoney = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height));
        viewBGCenter.addSubview(imgView)
        viewBGCenter.addSubview(lblText)
        viewBGCenter.backgroundColor = UIColor.clear
        viewBGCenter.center = backgroundViewHoney.center
        backgroundViewHoney.addSubview(viewBGCenter);
        self.backgroundView = backgroundViewHoney;
    }
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect( x: 0, y:  0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
}



extension UICollectionView {
    func reloadDataInMain() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
  
    func displayBackgroundText(text: String? = "No data found") {
        let lbl = UILabel();
        lbl.frame = CGRect(x: 10, y: 0, width: self.bounds.size.width - 20, height: self.bounds.size.height);
        lbl.text = text;
        lbl.textColor =  .black
        lbl.numberOfLines = 0;
        lbl.textAlignment = .center;
        lbl.font = UIFont.systemFont(ofSize: 12)

        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height));
        backgroundView.addSubview(lbl);
        self.backgroundView = backgroundView;
    }
    
    
    func removeBackgroundText() {
        self.backgroundView = nil
    }
        
    
}
