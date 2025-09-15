import { db } from "../firebaseAdmin.js";

export const createNewCuratorPanel = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.roomID;

  const { x, y, z, r, g, b, alpha, panelID, icon } = req.body || {};

  // Check x, y, z are numbers and not null/undefined
  if (
    typeof x !== "number" || isNaN(x) ||
    typeof y !== "number" || isNaN(y) ||
    typeof z !== "number" || isNaN(z)
  ) {
    return res.status(400).json({ message: "x, y, and z must be numbers and not null." });
  }

  // Check r, g, b are numbers between 0 and 255
  const isValidRGB = (val) => typeof val === "number" && !isNaN(val) && val >= 0 && val <= 255;
  if (!isValidRGB(r) || !isValidRGB(g) || !isValidRGB(b)) {
    return res.status(400).json({ message: "r, g, and b must be numbers between 0 and 255." });
  }

  // Check alpha is a number between 0 and 1
  if (
    typeof alpha !== "number" || isNaN(alpha) || alpha < 0 || alpha > 1
  ) {
    return res.status(400).json({ message: "alpha must be a decimal between 0 and 1." });
  }

  // Check required parameters
  if (!roomID || !museumID || !panelID || !icon) {
    return res.status(400).json({ message: "Missing parameter. Either museumID, roomID, panelID or icon. Please check parameters." });
  }

  try {
    // Prepare the data to insert
    const panelData = {
      museumID,
      roomID,
      x,
      y,
      z,
      r,
      g,
      b,
      alpha,
      panelID,
      icon
    };

    // Add the document to Firestore
    const docRef = await db.collection("CuratorPanelData").add(panelData);

    // Return the new document ID
    return res.status(201).json({ message: `Panel ${panelID} created. Document ${docRef}` });
  } catch (e) {
    console.error("Error creating document:", e);
    return res.status(503).json({ message: "Server could not connect to the database." });
  }
};


export const getCuratorPanels = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.roomID;

  try {
    const snapshot = await db.collection("CuratorPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .get();

    const panels = await Promise.all(snapshot.docs.map(async (doc) => {
      const data = doc.data();

      const text = await getTextFieldFromPanelID(museumID, roomID, data.panelID);

      return {
        id: doc.id,
        ...data,
        text,
      };
    }));

    return res.status(200).json(panels);
  } catch (e) {
    console.error("Error getting documents:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};


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

export const getAvailableCuratorPanels = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.roomID;

  try {
    // Get all panels for this museum/room
    const allPanelsSnapshot = await db.collection("PanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .get();

    // Extract full panel objects
    const allPanels = allPanelsSnapshot.docs.map(doc => ({
      panelID: doc.data().panelID,
      title: doc.data().title,
      text: doc.data().text,
    }));

    // Get already used panels
    const usedPanelsSnapshot = await db.collection("CuratorPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .get();

    const usedPanelIDs = usedPanelsSnapshot.docs.map(doc => doc.data().panelID);

    // Filter out used panels by panelID
    const availablePanels = allPanels.filter(panel => !usedPanelIDs.includes(panel.panelID));

    return res.status(200).json(availablePanels);

  } catch (e) {
    console.error("Error getting documents:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};

export const getPanelByID = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.roomID;
  const panelID = req.params.panelID;

  if (!museumID || !roomID || !panelID) {
    res.status(400).json({message: "Missing parameters. Please check request."})
  }

  try {
    // Get all panels for this museum/room
    const allPanelsSnapshot = await db.collection("PanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("panelID", "==", panelID)
      .get();

    // Extract full panel objects
    const allPanels = allPanelsSnapshot.docs.map(doc => ({
      panelID: doc.data().panelID,
      title: doc.data().title,
      text: doc.data().text,
    }));

    return res.status(200).json(allPanels[0]);

  } catch (e) {
    console.error("Error getting documents:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};

// Helper function
const getTextFieldFromPanelID = async (museumID, roomID, panelID) => {
  try {
    // Get all panels for this museum/room
    const allPanelsSnapshot = await db.collection("PanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("panelID", "==", panelID)
      .get();

    // Extract full panel objects
    const allPanels = allPanelsSnapshot.docs.map(doc => ({
      panelID: doc.data().panelID,
      title: doc.data().title,
      text: doc.data().text,
    }));

    return allPanels[0].text;
  } catch (e) {

  }

  return "";
}
