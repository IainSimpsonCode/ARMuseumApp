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