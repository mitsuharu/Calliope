//
//  ScanView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import SwiftUI

struct ScanView: View {
    @ObservedObject private var viewModel = ScanViewModel()
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        if viewModel.hasCandiates == false {
            VStack {
                ProgressView()
                Spacer().frame(height: 10)
                Button(action: {
                    router.goBack()
                }, label: {
                    Text("Back")
                })
            }
        } else {
            List {
                if 
                    let candiates = Binding($viewModel.manufacturerCandiates[.epson]),
                    candiates.count > 0
                {
                    Section(header: Text("EPSON")) {
                        ForEach(candiates, id: \.self) { item in
                            Button(action: {
                                viewModel.selectCandiate(deviceInfo: item.wrappedValue)
                            }) {
                                CandiateCell(deviceInfo: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                if
                    let candiates = Binding($viewModel.manufacturerCandiates[.bluetooth]),
                    candiates.count > 0
                {
                    Section(header: Text("Bluetooth devices (select SUNMI)")) {
                        ForEach(candiates, id: \.self) { item in
                            Button(action: {
                                viewModel.selectCandiate(deviceInfo: item.wrappedValue)
                            }) {
                                CandiateCell(deviceInfo: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScanView()
}
