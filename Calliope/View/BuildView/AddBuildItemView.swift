//
//  AddBuildItemView.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import SwiftUI

struct AddBuildItemView: View {
    @EnvironmentObject var viewModel: BuildViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section("Add BuildItem") {
                ForEach(BuildItem.BuildItemJob.allCases, id: \.self) { itemJob in
                    ListCell(title: itemJob.description) {
                        viewModel.items.append(BuildItem(itemJob: itemJob))
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
