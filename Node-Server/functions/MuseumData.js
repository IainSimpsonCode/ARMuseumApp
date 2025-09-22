import { db } from "../firebaseAdmin.js";

export const getMuseumNames = async (req, res) => {
  try {
    const snapshot = await db.collection("MuseumData").get();

    const museums = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    const museumNames = museums.map(museum => museum.museumID);

    return res.status(200).json(museumNames);
  } catch (e) {
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
}

export const getRoomNames = async (req, res) => {

  const museumID = req.params.museumID;

  if (!museumID) {
    res.status(400).json({message: "Missing museumID parameter."})
  }

  try {
    const snapshot = await db.collection("RoomData")
      .where("museumID", "==", museumID)
      .get();

    const rooms = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    const roomNames = rooms.map(room => room.roomID);

    return res.status(200).json(roomNames);
  } catch (e) {
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
}