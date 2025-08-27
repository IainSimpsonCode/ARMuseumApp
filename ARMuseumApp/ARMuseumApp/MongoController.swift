//import MongoSwift
//
//class MongoDBManager {
//    let client: MongoClient
//    let database: MongoDatabase
//
//    init() throws {
//        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
//        let settings = MongoClientSettings(eventLoopGroup: eventLoopGroup)
//        self.client = try MongoClient(settings: settings)
//        self.database = self.client.db("your_database_name")
//    }
//
//    // Create operation
//    func createDocument(document: Document) {
//        let collection = self.database.collection("your_collection_name")
//
//        do {
//            try collection.insertOne(document)
//            print("Document inserted successfully.")
//        } catch {
//            print("Failed to insert document: \(error)")
//        }
//    }
//
//    // Read operation
//    func readDocuments() {
//        let collection = self.database.collection("your_collection_name")
//
//        do {
//            let documents = try collection.find()
//            for document in documents {
//                print(document)
//            }
//        } catch {
//            print("Failed to read documents: \(error)")
//        }
//    }
//
//    // Update operation
//    func updateDocument(filter: Document, update: Document) {
//        let collection = self.database.collection("your_collection_name")
//
//        do {
//            try collection.updateOne(filter: filter, update: update)
//            print("Document updated successfully.")
//        } catch {
//            print("Failed to update document: \(error)")
//        }
//    }
//
//    // Delete operation
//    func deleteDocument(filter: Document) {
//        let collection = self.database.collection("your_collection_name")
//
//        do {
//            try collection.deleteOne(filter)
//            print("Document deleted successfully.")
//        } catch {
//            print("Failed to delete document: \(error)")
//        }
//    }
//
//    // Close the MongoDB connection
//    func closeConnection() {
//        do {
//            try self.client.syncClose().wait()
//            print("MongoDB connection closed.")
//        } catch {
//            print("Failed to close MongoDB connection: \(error)")
//        }
//    }
//}

// The following function will display an image using a url receieved from a Node server running on render. This is to test connection to the database

import SwiftUI

struct RoomImageView: View {
    @State private var uiImage: UIImage?

    var body: some View {
        VStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                ProgressView("Loading image...")
            }
        }
        .task {
            await fetchRoomImage(roomName: "testRoom")
        }
    }

    func fetchRoomImage(roomName: String) async {
        guard let url = URL(string: "https://armuseumapp.onrender.com/room/" + roomName + "/imageURL") else { return }

        do {
            // 1. Get the raw string from your endpoint
            let (data, _) = try await URLSession.shared.data(from: url)
            if let imageUrlString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               let imageUrl = URL(string: imageUrlString) {

                // 2. Fetch the actual image
                let (imgData, _) = try await URLSession.shared.data(from: imageUrl)
                self.uiImage = UIImage(data: imgData)
            }
        } catch {
            print("Error fetching image:", error)
        }
    }
}


import ARKit
import UIKit

struct DBController {
    static func getReferenceImages(for museum: String) async -> Set<ARReferenceImage> {
        guard let url = URL(string: "https://armuseumapp.onrender.com/museum/\(museum)/roomImageURLs") else {
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let rooms = try JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
                return []
            }

            var referenceImages: Set<ARReferenceImage> = []

            for room in rooms {
                if let imageUrlString = room["imageURL"],
                   let roomID = room["roomID"],
                   let imageUrl = URL(string: imageUrlString) {
                    
                    let (imgData, _) = try await URLSession.shared.data(from: imageUrl)
                    if let uiImage = UIImage(data: imgData),
                       let cgImage = uiImage.cgImage {
                        
                        let refImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.30)
                        refImage.name = roomID
                        referenceImages.insert(refImage)
                    }
                }
            }

            return referenceImages
        } catch {
            print("Error fetching reference images:", error)
            return []
        }
    }
}


