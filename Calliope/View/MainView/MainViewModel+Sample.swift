//
//  MainViewModel+Sample.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/07/06.
//

import Foundation

extension MainViewModel {
    
    struct SampleCommond {
        let title: String
        let jobs: [Print.Job]
        let uuid = UUID().uuidString
    }
        
    func mekeSampleCommonds() -> [SampleCommond] {
        
        var commonds: [SampleCommond] = []
        
        let commond1 = SampleCommond(
            title: "サンプルテキストの印刷",
            jobs: [
                .text(text: "渋谷での充実したSunday"),
                .text(text: "written by ChatGPT"),
                .feed(count: 1),
                .text(text: "今日はSunday、友達のKenと渋谷でランチをしました。美味しいラーメンを食べた後、映画「サムライアドベンチャー」を観に行きました。その後、カフェでコーヒーを飲みながら楽しい１日を過ごしました。"),
                .feed(count: 1),
            ]
        )
        commonds.append(commond1)
        
        if
            let image = UIImage(named: "himawari2.jpg"),
            let imageJob = Print.Job.makeJobImage(image: image, imageWidth: .width58, filename: "himawari")
        {
            let commond2 = SampleCommond(
                title: "サンプル画像の印刷",
                jobs: [
                    .text(text: "ひまわり"),
                    .text(text: "drawn by ChatGPT"),
                    .feed(count: 1),
                    imageJob,
                    .feed(count: 1)
                ]
            )
            commonds.append(commond2)
        }
        
//        let commond3 = SampleCommond(
//            title: "QRコードの印刷",
//            jobs: [
//                .text(text: "QRコードで「http://www.example.com」を印刷します"),
//                .qrCode(text: "http://www.example.com"),
//                .feed(count: 1),
//            ]
//        )
//        commonds.append(commond3)
        
        return commonds
        
    }
}
