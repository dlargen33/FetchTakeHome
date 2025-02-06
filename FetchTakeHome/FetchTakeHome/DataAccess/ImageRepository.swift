//
//  ImageRepository.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 1/30/25.
//

import CoreData

protocol ImageRepositoryProtocol {
    func getImageData(referenceID: String) async -> ImageData?
    
    @discardableResult
    func addImageData(imageData: ImageData) async -> Bool
}

class ImageRepository: ImageRepositoryProtocol {
    
    static let shared = ImageRepository()
    
    private var viewContext: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }
    
    private func newBackgroundContext()-> NSManagedObjectContext {
        PersistenceController.shared.container.newBackgroundContext()
    }
    
    func getImageData(referenceID: String) async -> ImageData?  {
        let context = newBackgroundContext()
        return await context.perform { () -> ImageData? in
            do {
                let fetchRequest: NSFetchRequest<ImageDataEntity> = ImageDataEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "referenceID == %@", referenceID)
                fetchRequest.fetchLimit = 1
                guard let imageDataEntity = try context.fetch(fetchRequest).first,
                      let referenceId = imageDataEntity.referenceID,
                      let data = imageDataEntity.imageData,
                      let expire = imageDataEntity.expire else {
                    return nil
                }
                return ImageData(referenceId: referenceId,
                                 data: data,
                                 expire: expire)
            }
            catch {
                //Better telemtry here.
                print("Failed to get image data for reference id: \(referenceID)")
                return nil
            }
        }
    }

    @discardableResult
    func addImageData(imageData: ImageData) async -> Bool {
        let context = newBackgroundContext()
        return await context.perform{
            do {
                let fetchRequest: NSFetchRequest<ImageDataEntity> = ImageDataEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "referenceID == %@", imageData.referenceId)
                
                if let existingEntity = try context.fetch(fetchRequest).first {
                    existingEntity.imageData = imageData.data
                    existingEntity.expire = imageData.expire
                }
                else {
                    let imageDataEntity = ImageDataEntity(context: context)
                    imageDataEntity.referenceID = imageData.referenceId
                    imageDataEntity.imageData = imageData.data
                    imageDataEntity.expire = imageData.expire
                }
                try context.save()
                return true
            }
            catch {
                //Better telemtry here.
                print("Error while adding image data for refernece id:\(imageData.referenceId) error: \(error)")
                return false
            }
        }
    }
}
