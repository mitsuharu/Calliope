//
//  BuildViewModel.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import Foundation

class BuildViewModel: ObservableObject {
    @Published var items: [BuildItem] = []
    @Published var title: String = ""
    @Published var showBuildItemSelection = false
        
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    private func fetchIndex(item: BuildItem) -> Int? {
        guard let index = items.firstIndex(where: {
            $0.id == item.id
        }) else {
            return nil
        }
        return index
    }
    
    func delete(item: BuildItem) {
        guard let index = fetchIndex(item: item) else {
            return
        }
        items.remove(at: index)
    }
    
    func update(item: BuildItem, object: BuildItem.BuildItemObject) {
        guard let index = fetchIndex(item: item) else {
            return
        }
        var nextItem = items[index]
        nextItem.object = object
        items[index] = nextItem
    }
    
    func save(){
        let jobs: [Print.Job] = items.compactMap { item in
            if case .text(let object) = item.object, let text = object {
                return Print.Job.text(text: text, size: .normal, style: .normal)
            } else if case .image(let object) = item.object, let image = object {
                return Print.Job.image(image: image, imageWidth: .width58)
            }
            return nil
        }
        
        if jobs.isEmpty {
            appStore.dispatch(onMain: ToastActions.Show(
                message: "印刷データが空だったので、保存しません",
                subMessage: nil)
            )
            return
        }
        
        let title = if title.isEmpty == false {
            title
        } else {
            curretDateString()
        }
        
        let buildJobs = PrinterState.BuildJob(
            title: title,
            jobs: jobs
        )
        appStore.dispatch(onMain: PrinterActions.AppendBuildJobs(buildJob: buildJobs))
    }
    
    
    func curretDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateString = dateFormatter.string(from: Date())
        return dateString
    }
    
}
