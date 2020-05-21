//
//  ContentView.swift
//  TwoWaySlideBar
//
//  Created by 蒋小寸 on 2020/5/20.
//  Copyright © 2020 蒋小寸. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            Spacer()

            Slider().padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct Slider: UIViewRepresentable {
    @State var minValue = ""
    @State var maxVale = ""
    typealias UIViewType = TwoWaySliderView
    func makeUIView(context: Context) -> TwoWaySliderView {
        return TwoWaySliderView.init(frame: .zero, sliderHeight: 2, minValue: 0, maxValue: 100)
    }
    func updateUIView(_ uiView: TwoWaySliderView, context: Context) {
        uiView.valueChanged = { (min, max) in
            self.minValue = "\(min)"
            self.maxVale = "\(max)"
            print("min:\(min),max\(max)")
        }
    }
}
