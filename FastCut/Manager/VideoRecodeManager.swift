//
//  VideoRecodeManager.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import CoreData

protocol VideoRecodeModel {
    var videoName: String { get }
    var videoPath: String { get }
    var saveDate: String { get }
}

public protocol VideoRecodeModelStore {
    func add(videoPath: String, videoName: String, saveDate: String)
    func remove(date: String, title: String)
    func removeAll()
    func count() -> Int?
    func removeLast()
}

class VideoRecodeManeger {
    static let shared = VideoRecodeManeger()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VideoRecode")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveVideoInfo(videoPath: String, videoName: String, saveDate: String, onSuccess: @escaping (Bool) -> Void) {
        let context = persistentContainer.viewContext
        if let entity = NSEntityDescription.entity(forEntityName: "VideoRecode", in: context) {
            if let videoRecodeData = NSManagedObject(entity: entity, insertInto: context) as? VideoRecode {
             //   videoRecodeData.videoPath = videoPath
                videoRecodeData.saveDate = saveDate
                videoRecodeData.videoName = videoName

                contextSave { success in
                    onSuccess(success)
                }
            } else {
                
            }
        }
    }

    func getSaveVideoRecodes() -> [VideoRecode] {
        var models = [VideoRecode]()
        // https://hanulyun.medium.com/swift-coredata로-데이터-저장-및-관리하기-19f61c95232f
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "VideoRecode")

        do {
            if let fetchResult = try context.fetch(fetchRequest) as? [VideoRecode] {
                models = fetchResult
            }
        } catch let error as NSError {
            print("Could not fetch🥺: \(error), \(error.userInfo), \(error.localizedDescription)")
        }
        return models
    }

    func deleteVideoFile() {
        let recodes = getSaveVideoRecodes()
        print(recodes.count, "지울 비디오 코어데이터 갯수")
        recodes.forEach { recode in
//            if let url = URL(string: recode.videoPath) {
//                let s = deleteVideoInfoData(item: recode)
//                print(s, "코아 데이터 삭제 결과")
//                if let data = try? Data(contentsOf: url) {
//                    print(data, "지울비디오")
//                    do {
//                        try FileManager.default.removeItem(at: url)
//
//                    } catch let e {
//                        print("경로에 폴더가 비어있거나 파일삭제에 실패함", e.localizedDescription)
//                    }
//                }
            }
    }
    

    @discardableResult
    func deleteVideoInfoData(item: VideoRecode) -> Bool {
        var successDelete = false
        persistentContainer.viewContext.delete(item)
        do {
            try persistentContainer.viewContext.save()
            successDelete = true
            print("비디오 삭제 성공")
        } catch let e {
            print("비디오 삭제 실패", e.localizedDescription)
            successDelete = false
        }
        return successDelete
    }
    
    func deleteOne(itemName: String) {
        let recodes = getSaveVideoRecodes()
        let item = recodes.filter { $0.videoName == itemName }
        print("삭제할 아이템 필터링", item)
        guard !item.isEmpty else { return }
        guard let recode = item.first else { return }
        do {
            try persistentContainer.viewContext.save()
//            if let url = URL(string: recode.videoPath) {
//                let s = deleteVideoInfoData(item: recode)
//                print(s, "코아 데이터 삭제 결과")
//                if let data = try? Data(contentsOf: url) {
//                    print(data, "지울비디오")
//                    do {
//                        try FileManager.default.removeItem(at: url)
//                        
//                    } catch let e {
//                        print("경로에 폴더가 비어있거나 파일삭제에 실패함", e.localizedDescription)
//                    }
//                }
//            }
        } catch let e {
            print(e.localizedDescription)
        }
        
    }

    func deleteReport() {
        let context = taskContext()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: VideoRecode.fetchRequest())

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("removeAll Person error: \(error)")
        }
    }

    func taskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        setBackgroundContext(taskContext)
        return taskContext
    }

    fileprivate func setBackgroundContext(_ context: NSManagedObjectContext) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy // in-memory와 영구 저장소 merge 충돌: in-memory우선
        context.undoManager = nil // nil인 경우, 실행 취소를 비활성화 (iOS에 디폴트값은 nil, macOS에서는 기본적으로 제공)
    }

    fileprivate func contextSave(onSuccess: (Bool) -> Void) {
        let context = persistentContainer.viewContext
        do {
            try context.save()
            onSuccess(true)
        } catch let error as NSError {
            print("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
}
