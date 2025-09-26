import { db } from "../firebaseAdmin.js";

export const addDrawingPoint = async (req, res) => {
  const sessionID = req.params.accessToken;
  const roomID = req.params.roomID;
  const museumID = req.params.museumID;

  const { x, y, z, radius, drawingID } = req.body || {};

  if (!sessionID || !museumID || !roomID) {
    return res.status(400).json({message: "Missing museumID, roomID or sessionID."})
  }
  if (!x || !y || !z || !radius || !drawingID) {
    return res.status(400).json({message: "Missing parameter. Either x, y, z, radius or drawingID."})
  }

  try {

    const drawingData = {
      museumID,
      roomID,
      sessionID,
      drawingID,
      x,
      y,
      z,
      radius
    };

    // Create or overwrite the document
    await db.collection("DrawingPointData").doc().set(drawingData);

    return res.status(201).json({ message: "Point added sucessfuly." });
  } catch (e) {
    console.error("Error creating drawing point:", e);
    return res.status(503).json({ message: "Server could not connect to the database." });
  }
};

export const getDrawingPoint = async (req, res) => {
  const sessionID = req.params.accessToken;
  const roomID = req.params.roomID;
  const museumID = req.params.museumID;

  if (!sessionID || !museumID || !roomID) {
    return res.status(400).json({message: "Missing museumID, roomID or sessionID."})
  }

  try {
    const snapshot = await db.collection("DrawingPointData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("sessionID", "==", sessionID)
      .get();

    const points = await Promise.all(snapshot.docs.map(async (doc) => {
      const data = doc.data();

      return data;
    }));

    return res.status(200).json(points);
  } catch (e) {
    console.error("Error getting documents:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};

export const deleteDrawingPoint = async (req, res) => {
  const sessionID = req.params.accessToken;
  const roomID = req.params.roomID;
  const museumID = req.params.museumID;
  const drawingID = req.params.drawingID;

  if (!sessionID || !museumID || !roomID || !drawingID) {
    return res.status(400).json({message: "Missing museumID, roomID, drawingID or sessionID."})
  }

  try {
    const snapshot = await db.collection("DrawingPointData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("sessionID", "==", sessionID)
      .where("drawingID", "==", drawingID)
      .get();

    await Promise.all(snapshot.docs.map(async (doc) => {
      await doc.ref.delete();
    }));

    return res.status(200).json({message: "Point deleted."});
  } catch (e) {
    console.error("Error getting documents:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};