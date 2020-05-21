//
//  TwoWaySliderView.swift
//  TwoWaySlideBar
//
//  Created by 蒋小寸 on 2020/5/20.
//  Copyright © 2020 蒋小寸. All rights reserved.
//

import UIKit
import SnapKit

//双向滑杆
typealias ValueChanged =  (_ minValue : CGFloat ,_ maxValue : CGFloat)->Void
typealias isValueChanging =  (_ isChanging : Bool)->Void //是否正在滑动滑杆
class TwoWaySliderView : UIView{
    var isSlider = false
    let sliderBar = UIView()
    let sliderBackGround = UIView()
    let minButton = TwoWaySliderPanButton(type: .custom)
    let maxButton = TwoWaySliderPanButton(type: .custom)
    let minView = UIView()
    let maxView = UIView()
    let midView = UIView()
    var valueChanged : ValueChanged?
    var isValueChanged : isValueChanging?
    
    var sliderHeight = 2
    var isToggleOrientation = false //如果为true，则拖动最大滑块往左和最小滑块重叠时继续往左滑可以更改最小值
    var minValue : CGFloat = 0{
        didSet{
            currentMinValue = minValue
        }
    }
    var maxValue : CGFloat = 0{
        didSet{
            if maxValue < minValue {
                maxValue = minValue
            }
            currentMaxValue = maxValue
        }
    }
    var currentMinValue : CGFloat = 0{//根据百分比计算出 (max-min)*minPercent + min
        didSet{
            let max = currentMaxValue == 0 ? maxValue : currentMaxValue
            
            if currentMinValue < minValue {
                currentMinValue = minValue
            }else if currentMinValue > max{
                currentMinValue = max
            }
            minButton.snp.updateConstraints { (make) in
                if maxValue == minValue{
                    make.centerX.equalTo(self.width * 0)
                }else{
                    let percent = (currentMinValue - minValue )/(maxValue - minValue)
                    make.centerX.equalTo(self.width * percent)
                }

            }

        }
    }
    var currentMaxValue : CGFloat = 0{ //根据百分比计算出 (max-min)*maxPercent + min
        didSet{
            let min = currentMinValue == 0 ? minValue : currentMinValue
            if currentMaxValue > maxValue {
                currentMaxValue = maxValue
            }else if currentMaxValue < min{
                currentMaxValue = min
            }
            maxButton.snp.updateConstraints { (make) in
                if maxValue == minValue{
                    make.centerX.equalTo(self.width * 0)
                }else{
                    let percent = (currentMaxValue - minValue )/(maxValue - minValue)
                    make.centerX.equalTo(self.width * percent)
                }
            }


        }

    }
    private var minPercent : CGFloat{
        get {
            if maxValue != minValue {
                return (currentMinValue - minValue )/(maxValue - minValue)
            }
            
            return 0
            
        }
    }
    private var maxPercent : CGFloat{
        get {
            if maxValue != minValue {
                return (currentMaxValue - minValue )/(maxValue - minValue)
            }
            return 0
        }
    }

    var oldPoint : CGPoint = .zero
    
    convenience init(frame: CGRect,sliderHeight : CGFloat = 2,minValue : CGFloat = 0,maxValue : CGFloat = 0) {
        self.init()
        self.frame = frame
        self.minValue = minValue
        self.maxValue = maxValue
        self.setUpSubviews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpSubviews() {
        sliderBackGround.backgroundColor = UIColor(white: 221 / 255.0 , alpha: 1)
        self.addSubview(sliderBackGround)
        
        sliderBackGround.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.centerY.equalTo(self.centerY)
            make.height.equalTo(sliderHeight)

        }
        self.addSubview(sliderBar)
        sliderBar.backgroundColor = UIColor.red
        
        let buttons = [minButton,maxButton]
        for button in buttons{

            button.setImage(#imageLiteral(resourceName: "service_recruit_filter_select_bar"), for: .normal)
            button.setImage(#imageLiteral(resourceName: "service_recruit_filter_select_bar"), for: [.normal,.highlighted])
            //button.backgroundColor = .darkGray
            button.enlargedInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.addSubview(button)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(buttonPan(_ :)))
            button.addGestureRecognizer(pan)
        }
        
        minButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerY.equalTo(self.centerY)
            make.centerX.equalTo(self.width*0)
        }
        
        //maxButton.backgroundColor = UIColor.themeColor()
        maxButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerY.equalTo(self.centerY)
            make.centerX.equalTo(self.width*0.5)
        }
        
        let views : [UIView] = [minView,maxView]
        for item in views{
            item.backgroundColor = UIColor(white: 221 / 255.0 , alpha: 1)
            self.addSubview(item)
        }
        
        minView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(minButton.snp.centerX)
            make.top.equalTo(sliderBar.snp.top)
            make.height.equalTo(sliderBar.height)
        }
    
        maxView.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.left.equalTo(maxButton.snp.centerX)
            make.top.equalTo(sliderBar.snp.top)
            make.height.equalTo(sliderBar.height)
        }
        
        sliderBar.snp.makeConstraints { (make) in
            make.left.equalTo(minButton.snp.centerX)
            make.right.equalTo(maxButton.snp.centerX)
            make.centerY.equalTo(self.centerY)
            make.height.equalTo(sliderHeight)
        }

    }
    
    @objc func buttonPan( _ pgr : UIPanGestureRecognizer){
        let point = pgr.translation(in: self)
        var center : CGPoint = .zero
        if oldPoint != .zero {
           center = oldPoint
        }
        if (pgr.state == UIGestureRecognizer.State.began) {
            center = (pgr.view?.center)!
            self.isSlider = true
            self.isValueChanged?(self.isSlider)
            oldPoint = center
        }else if(pgr.state == UIGestureRecognizer.State.ended || pgr.state == UIGestureRecognizer.State.cancelled){
            oldPoint = .zero
            self.isToggleOrientation = false
            self.isSlider = false
            self.isValueChanged?(self.isSlider)
            return
        }
        if Int(currentMinValue) == Int(currentMaxValue){
            if (pgr.view == minButton && point.x > 0) || (pgr.view == maxButton && point.x < 0) {
                self.isToggleOrientation = true
            }else{
                self.isToggleOrientation = false
            }
        }
        if pgr.view == minButton {
            if self.width != 0{
                if isToggleOrientation {
                    let currentMaxValue = minValue + (maxValue - minValue) * ((max(center.x + point.x,minButton.centerX)) / self.width)
                    self.setCurrentMaxValue(currentMaxValue: currentMaxValue)
                }else{
                    let currentMinValue = minValue + (maxValue - minValue) * ((min(center.x + point.x,maxButton.centerX)) / self.width)
                    self.setCurrentMinValue(currentMinValue: currentMinValue)
                }
  
            }
            
        }else{
            if (self.width != 0){
                if isToggleOrientation || (self.currentMaxValue == self.maxValue && (self.maxValue - self.currentMinValue) < 4){ //如果已经到最大值还继续右滑，默认为修改最小值
                    let currentMinValue = minValue + (maxValue - minValue) * ((min(center.x + point.x,maxButton.centerX)) / self.width)
                    self.setCurrentMinValue(currentMinValue: currentMinValue)
                }else{
                    let currentMaxValue = minValue + (maxValue - minValue) * ((max(center.x + point.x,minButton.centerX)) / self.width)
                    self.setCurrentMaxValue(currentMaxValue: currentMaxValue)
                }
            }
        }
        self.valueChanged?(currentMinValue,currentMaxValue)
    }
    func setCurrentMinValue( currentMinValue : CGFloat) {
        self.currentMinValue = round(currentMinValue)
        let max = currentMaxValue == 0 ? maxValue : currentMaxValue
        if self.currentMinValue < minValue {
            self.currentMinValue = minValue
        }else if currentMinValue > max{
            self.currentMinValue = max
        }
        minButton.snp.updateConstraints { (make) in
            if maxValue == minValue{
                make.centerX.equalTo(self.width * 0)
            }else{
                let percent = (round(currentMinValue) - minValue )/(maxValue - minValue)
                make.centerX.equalTo(self.width * percent)
            }
        }
    }
    func setCurrentMaxValue( currentMaxValue : CGFloat) {
        self.currentMaxValue = round(currentMaxValue)
        let min = currentMinValue == 0 ? minValue : currentMinValue
        if self.currentMaxValue > maxValue {
            self.currentMaxValue = maxValue
        }else if self.currentMaxValue < min{
            self.currentMaxValue = min
        }
        maxButton.snp.updateConstraints { (make) in
            if maxValue == minValue{
                make.centerX.equalTo(self.width * 0)
            }else{
                let percent = (round(currentMaxValue) - minValue )/(maxValue - minValue)
                make.centerX.equalTo(self.width * percent)
            }
        }
    }
}

//扩大点击范围
class TwoWaySliderPanButton : UIButton{
    var enlargedInset : UIEdgeInsets = .zero
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let enlargedRect = CGRect(x: self.bounds.origin.x - self.enlargedInset.left, y: self.bounds.origin.y - self.enlargedInset.top, width: self.bounds.size.width + self.enlargedInset.left+self.enlargedInset.right , height: self.bounds.size.height + self.enlargedInset.top + self.enlargedInset.bottom)
        
        if enlargedRect.equalTo(self.bounds) {
            return super.point(inside: point, with: event)
        }
        let _ = enlargedRect.contains(point)
        return enlargedRect.contains(point) ? true:false
    }
}
