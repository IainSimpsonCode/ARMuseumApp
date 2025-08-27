import express from "express";
import { initializeApp } from "firebase/app";
import { getFirestore, collection, query, where, getDocs } from "firebase/firestore";
import { getStorage, ref, getDownloadURL } from "firebase/storage";

const firebaseConfig = {
  apiKey: "AIzaSyDlf4ulcrb4zoqHeojwpJu9zfVUJial9UU",
  authDomain: "armuseumapp-c7df5.firebaseapp.com",
  projectId: "armuseumapp-c7df5",
  storageBucket: "armuseumapp-c7df5.firebasestorage.app",
  messagingSenderId: "25367058804",
  appId: "1:25367058804:web:eeb18de2fde181afc83421",
  measurementId: "G-5EPLJ2DPL7"
};

// Init Firebase
const appFirebase = initializeApp(firebaseConfig);
const db = getFirestore(appFirebase);
const storage = getStorage(appFirebase);

const app = express();
const PORT = process.env.PORT || 4000 // process.env.PORT will be defined by render

// Return a whole document from the RoomData collection in the database where the room ID matches :id
// If there are multiple matches from :id, the first document is returned
app.get("/museum/:museum/room/:id", async (req, res) => {
  const roomId = req.params.id;
  const museum = req.params.museum;

  try {
    const roomQuery = query(
      collection(db, "RoomData"),
      where("roomID", "==", roomId),
      where("museum", "==", museum)
    );

    const querySnapshot = await getDocs(roomQuery);

    if (querySnapshot.empty) {
      return res.status(404).json({ message: `Room with ID '${roomId}' not found.` });
    }

    const roomData = querySnapshot.docs[0].data();
    res.json(roomData);

  } catch (error) {
    console.error("Error fetching room:", error);
    res.status(500).json({ error: "Failed to fetch room data" });
  }
});

// Finds the document in the RoomData collection in the database where roomID matches :id. Returns a link to the rooms marker image
// If there are multiple matches from :id, the first document is used
app.get("/museum/:museum/room/:id/imageURL", async (req, res) => {
  const roomId = req.params.id;
  const museum = req.params.museum;

  try {
    // Build a query to find the required data
    const roomQuery = query(
      collection(db, "RoomData"),
      where("roomID", "==", roomId),
      where("museum", "==", museum)
    );
    // Use the query to get any matching documents
    const querySnapshot = await getDocs(roomQuery);

    // If nothing was returned, send back an error message
    if (querySnapshot.empty) {
      return res.status(404).json({ message: `Room with ID '${roomId}' not found.` });
    }

    // If multiple docs matched the query, only use the first match
    const roomData = querySnapshot.docs[0].data();

    // If the image field was blank, return an error
    if (!roomData.markerImageLocation) {
      res.status(404).json({ error: "Image not set for this room" });
    }

    // Get the image location from the document and convert it into a useable url to get the image
    const storageRef = ref(storage, roomData.markerImageLocation);
    const url = await getDownloadURL(storageRef);

    // Return a url to the actual image
    res.send(url);

  } catch (error) {
    console.error("Error fetching room:", error);
    res.status(500).json({ error: "Failed to fetch room data" });
  }
});

app.get("/museum/:museum/roomImageURLs", async (req, res) => {
  const museum = req.params.museum;

  try {
    const roomQuery = query(
      collection(db, "RoomData"),
      where("museum", "==", museum)
    );

    const querySnapshot = await getDocs(roomQuery);

    if (querySnapshot.empty) {
      return res.status(404).json({ message: `No rooms found for museum '${museum}'.` });
    }

    const results = [];

    for (const doc of querySnapshot.docs) {
      const roomData = doc.data();
      if (roomData.markerImageLocation) {
        const storageRef = ref(storage, roomData.markerImageLocation);
        const url = await getDownloadURL(storageRef);

        results.push({
          roomID: roomData.roomID,
          imageURL: url
        });
      }
    }

    res.json(results);

  } catch (error) {
    console.error("Error fetching room images:", error);
    res.status(500).json({ error: "Failed to fetch room image URLs" });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
