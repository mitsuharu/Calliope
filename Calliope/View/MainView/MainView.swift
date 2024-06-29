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
            Section("プリセットされた印刷コマンド") {
                ForEach(viewModel.sampleCommonds, id: \.uuid) { item in
                    ListCell(title: item.title) {
                        viewModel.run(jobs: item.jobs)
                    }
                }
            }
            Section("印刷コマンドをビルドする") {
                ListCell(title: "Build", accessory: .disclosureIndicator) {
                    NavigationRouter.shared.navigate(.build)
                }
            }
//            Section {
//                // build 済みの印刷コマンドを一覧する。印刷＆削除
//                ListCell(title: "Build 1") {
//                    NavigationRouter.shared.navigate(.build)
//                } deleteSwipeAction: {
//                    print("delete")
//                }
//            }
        }
    }
}

#Preview {
    MainView()
}
