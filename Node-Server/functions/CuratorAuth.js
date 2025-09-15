import { db } from "../firebaseAdmin.js";

export const validateCuratorLogin = async (req, res) => {
  const museumID = req.params.museumID;
  const { curatorID, curatorPassword } = req.body || {};

  if (!museumID || !curatorID || !curatorPassword) {
    return res.status(400).json({
      message: "MuseumID, curatorID or curatorPassword is missing. Please check parameters."
    });
  }

  try {
    // Get the museum by museumID
    const snapshot = await db.collection("MuseumData")
      .where("museumID", "==", museumID)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "Museum not found." });
    }

    // Only use the first matching document
    const museumDoc = snapshot.docs[0].data();

    // Check if curatorID and curatorPassword match any curator in the array
    const curatorMatch = museumDoc.curators.find(
      c => c.curatorUsername === curatorID && c.curatorPassword === curatorPassword
    );

    if (curatorMatch) {
      return res.status(200).json({ message: "Login successful." });
    } else {
      return res.status(401).json({ message: "Invalid curatorID or curatorPassword." });
    }

  } catch (e) {
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};
