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
                PrinterInfoCell(name: viewModel.name, uuid: viewModel.uuid)
            }
            Section("プリセットされた印刷コマンド") {
                ForEach(viewModel.sampleCommonds, id: \.uuid) { item in
                    ListCell(title: item.title) {
                        viewModel.run(jobs: item.jobs)
                    }
                }
            }
            Section("印刷コマンドをビルドする") {
                ListCell(title: "ビルド画面に遷移する", accessory: .disclosureIndicator) {
                    NavigationRouter.shared.navigate(.build)
                }
            }
            Section {
                ForEach(viewModel.buildJobs, id: \.id) { buildJob in
                    ListCell(title: buildJob.title) {
                        viewModel.runBuildJobs(buildJob: buildJob)
                    }
                }
            } header: {
                if viewModel.buildJobs.isEmpty == false {
                    Text("ビルドした印刷コマンド")
                }
            }
            
            Section {
            } header: {
                Text("このアプリは EPSON および SUNMI が販売・製造する一部のサーマルプリンターに対応しています。")
            }
        }
    }
}

#Preview {
    MainView()
}
