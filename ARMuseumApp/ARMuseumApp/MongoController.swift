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
            await fetchRoomImage()
        }
    }

    func fetchRoomImage() async {
        guard let url = URL(string: "https://armuseumapp.onrender.com/room/testRoom/imageURL") else { return }

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

