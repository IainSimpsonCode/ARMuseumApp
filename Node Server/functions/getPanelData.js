import { db } from "../firebaseAdmin.js";

export const createNewCuratorPanel = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.museumID;

  const { x, y, z, red, green, blue, alpha, text, icon } = req.body || {};

  // Check x, y, z are numbers and not null/undefined
  if (
    typeof x !== "number" || isNaN(x) ||
    typeof y !== "number" || isNaN(y) ||
    typeof z !== "number" || isNaN(z)
  ) {
    return res.status(400).json({ message: "x, y, and z must be numbers and not null." });
  }

  // Check red, green, blue are integers 0-255
  const rgb = [red, green, blue].map(v => Math.round(v));
  if (
    rgb.some(v => typeof v !== "number" || isNaN(v) || v < 0 || v > 255)
  ) {
    return res.status(400).json({ message: "red, green, and blue must be integers between 0 and 255." });
  }

  // Check alpha is a number between 0 and 1
  if (
    typeof alpha !== "number" || isNaN(alpha) || alpha < 0 || alpha > 1
  ) {
    return res.status(400).json({ message: "alpha must be a decimal between 0 and 1." });
  }

  // Check text is supplied for others
  if (!roomID || !museumID || !text || !icon) {
    return res.status(400).json({ message: "Missing parameter. Either museumID, roomID, text or icon. Please check parameters." });
  }

  try {
    // Prepare the data to insert
    const panelData = {
      museumID,
      roomID,
      x,
      y,
      z,
      red: Math.round(red),
      green: Math.round(green),
      blue: Math.round(blue),
      alpha,
      text,
      icon
    };

    // Add the document to Firestore
    const docRef = await db.collection("CuratorPanelData").add(panelData);

    // Return the new document ID
    return res.status(201).json({ panelID: docRef.id });
  } catch (e) {
    console.error("Error creating document:", e);
    return res.status(503).json({ message: "Server could not connect to the database." });
  }
}

export const getCuratorPanels = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.museumID;

  try {
    const snapshot = await db.collection("CuratorPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .get();

    const panels = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    return res.status(200).json(panels);
  } catch (e) {
    console.error("Error getting documents:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
}

export const updateCuratorPanel = async (req, res) => {
  const { docID } = req.body;
  const updateData = req.body.fields;

  if (!docID || !updateData || typeof updateData !== "object") {
    return res.status(400).json({ message: "docID and fields to update must be provided." });
  }

  try {
    const docRef = db.collection("CuratorPanelData").doc(docID);

    // Check if document exists
    const docSnap = await docRef.get();
    if (!docSnap.exists) {
      return res.status(400).json({ message: `Document with ID ${docID} not found.` });
    }

    await docRef.update(updateData);
    return res.status(200).json({ message: "Document updated successfully." });
  } catch (e) {
    console.error("Error updating document:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};

export const deleteCuratorPanel = async (req, res) => {
  const { docID } = req.body;  // or use req.params

  if (!docID) {
    return res.status(400).json({ message: "docID must be provided." });
  }

  try {
    const docRef = db.collection("CuratorPanelData").doc(docID);

    // Check if document exists
    const docSnap = await docRef.get();
    if (!docSnap.exists) {
      return res.status(400).json({ message: `Document with ID ${docID} not found.` });
    }

    await docRef.delete();
    return res.status(200).json({ message: "Document deleted successfully." });
  } catch (e) {
    console.error("Error deleting document:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};
