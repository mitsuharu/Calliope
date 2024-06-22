//
//  MainView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/05/03.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var viewModel = MainViewModel()
    
    var body: some View {
        List {
            Section("選択されたサーマルプリンター") {
                PrinterInfoCell(title: "NAME", detail: viewModel.name)
                PrinterInfoCell(title: "UUID", detail: viewModel.uuid)
            }
            Section("印刷コマンド") {
                ForEach(viewModel.sampleCommonds, id: \.uuid) { item in
                    Button {
                        viewModel.run(jobs: item.jobs)
                    } label: {
                        PrintCell(title: item.title)
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
