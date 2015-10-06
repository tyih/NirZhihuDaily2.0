//
//  WebViewController.swift
//  zhihuDaily 2.0
//
//  Created by Nirvana on 10/5/15.
//  Copyright © 2015 NSNirvana. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WebViewController: UIViewController, UIScrollViewDelegate, ParallaxHeaderViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var webHeaderView: ParallaxHeaderView!
    var orginalHeight: CGFloat = 0
    var titleLabel: myUILabel!
    var sourceLabel: UILabel!
    var blurView: GradientView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置展示的ImageView
        let imageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, 223))
        imageView.contentMode = .ScaleAspectFill
        imageView.image = UIImage(named: "WebTopImage")
       
        //保存初始Frame
        orginalHeight = imageView.frame.height
        
        //设置Image上的TitleLabel
        titleLabel = myUILabel(frame: CGRectMake(15, orginalHeight - 80, self.view.frame.width - 30, 60))
        titleLabel.font = UIFont(name: "STHeitiSC-Medium", size: 21)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.shadowColor = UIColor.blackColor()
        titleLabel.shadowOffset = CGSizeMake(0, 1)
        titleLabel.verticalAlignment = VerticalAlignmentBottom
        titleLabel.numberOfLines = 0
        titleLabel.text = "青蒿素的研发方法，早有先例，也不会是最后一例"
        imageView.addSubview(titleLabel)
        
        //设置Image上的Image_SourceLabel
        sourceLabel = UILabel(frame: CGRectMake(15, orginalHeight - 20, self.view.frame.width - 30, 15))
        sourceLabel.font = UIFont(name: "Helvetica", size: 9)
        sourceLabel.textColor = UIColor.whiteColor()
        sourceLabel.textAlignment = NSTextAlignment.Right
        let sourceLabelText = "Ton Rulkens / CC BY"
        sourceLabel.text = "图片：" + sourceLabelText
        imageView.addSubview(sourceLabel)
        
        //设置Image上的BlurView
        blurView = GradientView(frame: CGRectMake(0, -30, self.view.frame.width, orginalHeight + 30), type: TRANSPARENT_GRADIENT_TWICE_TYPE)
        imageView.addSubview(blurView)
        
        //使titleLabel不被遮挡
        imageView.bringSubviewToFront(titleLabel)
        
        //将其添加到ParallaxView
        webHeaderView = ParallaxHeaderView.parallaxWebHeaderViewWithSubView(imageView, forSize: CGSizeMake(self.view.frame.width, 223)) as! ParallaxHeaderView
        webHeaderView.delegate = self
        
        //将ParallaxView添加到WebView下层的ScrollView上并对ScrollView做基本配置
        self.webView.scrollView.addSubview(webHeaderView)
        self.webView.scrollView.delegate = self
        self.webView.scrollView.clipsToBounds = false
        self.webView.scrollView.showsVerticalScrollIndicator = false
        
        //获取网络数据，包括body css image image_source title 并拼接body与css后加载
        Alamofire.request(.GET, "http://news-at.zhihu.com/api/4/news/7235309").responseJSON { (_, _, dataResult) -> Void in
            let body = JSON(dataResult.value!)["body"].string!
            let css = JSON(dataResult.value!)["css"][0].string!
            
            var html = "<html>"
            html += "<head>"
            html += "<link rel=\"stylesheet\" href="
            html += css
            html += "</head>"
            html += "<body>"
            html += body
            html += "</body>"
            html += "</html>"
            
            self.webView.loadHTMLString(html, baseURL: nil)
        }
    }

    //实现Parallax效果
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let incrementY = scrollView.contentOffset.y
        
        if incrementY < 0 {
            titleLabel.frame = CGRectMake(15, orginalHeight - 80 - incrementY, self.view.frame.width - 30, 60)
            sourceLabel.frame = CGRectMake(15, orginalHeight - 20 - incrementY, self.view.frame.width - 30, 15)
        }
        blurView.frame = CGRectMake(0, -30, self.view.frame.width, orginalHeight - incrementY + 30)
        webHeaderView.layoutWebHeaderViewForScrollViewOffset(scrollView.contentOffset)
    }
    
    //设置滑动极限 修改该值需要一并更改layoutWebHeaderViewForScrollViewOffset中的对应值
    func lockDirection() {
        self.webView.scrollView.contentOffset.y = -85
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
