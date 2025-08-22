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
const PORT = 3000;

// Return a whole document from the RoomData collection in the database where the room ID matches :id
// If there are multiple matches from :id, the first document is returned
app.get("/room/:id", async (req, res) => {
  const roomId = req.params.id;

  try {
    const roomQuery = query(
      collection(db, "RoomData"),
      where("roomID", "==", roomId)
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
app.get("/room/:id/imageURL", async (req, res) => {
  const roomId = req.params.id;

  try {
    const roomQuery = query(
      collection(db, "RoomData"),
      where("roomID", "==", roomId)
    );

    const querySnapshot = await getDocs(roomQuery);

    if (querySnapshot.empty) {
      return res.status(404).json({ message: `Room with ID '${roomId}' not found.` });
    }

    const roomData = querySnapshot.docs[0].data();

    if (!roomData.markerImageLocation) {
      res.status(404).json({ error: "Image not set for this room" });
    }

    const storageRef = ref(storage, roomData.markerImageLocation);
    const url = await getDownloadURL(storageRef);

    res.send(url);

  } catch (error) {
    console.error("Error fetching room:", error);
    res.status(500).json({ error: "Failed to fetch room data" });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
