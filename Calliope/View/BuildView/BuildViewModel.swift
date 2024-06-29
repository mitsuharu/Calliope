//
//  BuildViewModel.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/29.
//

import Foundation

class BuildViewModel: ObservableObject {
    @Published var items: [BuildItem] = []
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
        // TODO: saga を呼んで、PrintJobs形式にして保存する
        
        let jobs: [Print.Job] = items.compactMap { item in
            if case .text(let object) = item.object, let text = object {
                return Print.Job.text(text: text, size: .normal, style: .normal)
            } else if case .image(let object) = item.object, let image = object {
                return Print.Job.image(image: image, imageWidth: .fiftyEight)
            }
            return nil
        }
        
        if jobs.isEmpty {
            appStore.dispatch(onMain: ToastActions.ShowToast(message: "印刷データが空だったので、保存しません"))
            return
        }
        
        let buildJobs = PrinterState.BuildJob(
            title: curretDateString(),
            jobs: jobs
        )
        appStore.dispatch(onMain: PrinterActions.AppendBuildJobs(buildJob: buildJobs))
    }
    
    
    func curretDateString() -> String {
        // 現在の日付と時間を取得
        let currentDate = Date()

        // DateFormatterを作成
        let dateFormatter = DateFormatter()

        // カレンダーをグレゴリオ暦に設定
        dateFormatter.calendar = Calendar(identifier: .gregorian)

        // フォーマットを設定
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // 日付を文字列に変換
        let dateString = dateFormatter.string(from: currentDate)

        // 結果を出力
        return dateString
    }
    
}
