import { db } from "../firebaseAdmin.js";
import { getIconFieldFromPanelID, getLongTextFieldFromPanelID, getTextFieldFromPanelID } from "./PanelData.js";

export const getCommunitySessions = async (req, res) => {

  const museumID = req.params.museumID;

  if (!museumID ) {
    return res.status(400).json({ message: "Missing parameter museumID." });
  }

  try {
    const snapshot = await db.collection("CommunitySessionData")
      .where("museumID", "==", museumID)
      .get();

    const sessions = snapshot.docs.map(doc => {
    const data = doc.data();
    return {
      sessionID: data.sessionID,
      isPrivate: data.isPrivate
    };
  });

    const sessionIDs = sessions.map(session => session.sessionID);

    return res.status(200).json(sessions);
  } catch (e) {
    console.error("Error getting sessionIDs:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
}

export const createCommunitySession = async (req, res) => {
  const museumID = req.params.museumID;

  const { sessionID, sessionPassword } = req.body || {};

  // Check text is supplied for ID, password and museumID
  if (!museumID || !sessionID || !sessionPassword) {
    return res.status(400).json({ message: "Missing parameter. Either museumID, sessionID or sessionPassword." });
  }

  // Check whether the sessionID is already in use
  try {

    const snapshot = await db.collection("CommunitySessionData")
      .where("sessionID", "==", sessionID)
      .get();

    const sessions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    // If 1 or more sessions have the supplied sessionID, sessionID is taken and new session with that ID cant be created
    if (sessions.length > 0) {
      return res.status(409).json({ message: "Session with the supplied ID already exists." });
    }

  } catch (e) {
    console.error("Error checking sessionID:", e);
    return res.status(503).json({ message: "Server could not connect to the database." });
  }

  // If sessionID is valid, create the session
  try {
    // Prepare the data to insert
    const panelData = {
      museumID,
      sessionID,
      sessionPassword
    };

    // Add the document to Firestore
    const docRef = await db.collection("CommunitySessionData").add(panelData);

    // Return the new document ID
    return res.status(201).json({ message: "Session created." });
  } catch (e) {
    console.error("Error creating document:", e);
    return res.status(503).json({ message: "Server could not connect to the database." });
  }
}

export const deleteCommunitySession = async (req, res) => {
  const museumID = req.params.museumID;

  const { sessionID, sessionPassword } = req.body || {};

  // Check text is supplied for ID, password and museumID
  if (!museumID || !sessionID || !sessionPassword) {
    return res.status(400).json({ message: "Missing parameter. Either museumID, sessionID or sessionPassword." });
  }  

  try {
    const snapshot = await db.collection("CommunitySessionData")
      .where("museumID", "==", museumID)
      .where("sessionID", "==", sessionID)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ message: `No documents found with sessionID ${sessionID}.` });
    }

    // Delete any docs with matching sessionID
    const deletePromises = snapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(deletePromises);

    return res.status(200).json({ message: "Document deleted successfully." });
  } catch (e) {
    console.error("Error deleting document:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};

export const joinCommunitySession = async (req, res) => {
  const museumID = req.params.museumID;
  const { sessionID, sessionPassword } = req.body || {};

  if (!museumID) {
    return res.status(400).json({ message: "Missing parameter museumID." });
  }

  if (!sessionID || !sessionPassword) {
    return res.status(400).json({ message: "Missing sessionID or sessionPassword in request body." });
  }

  try {
    // Query the CommunitySessionData collection for a document matching both museumID and sessionID
    const snapshot = await db.collection("CommunitySessionData")
      .where("museumID", "==", museumID)
      .where("sessionID", "==", sessionID)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "No session found with the provided sessionID." });
    }

    const doc = snapshot.docs[0];
    const data = doc.data();
    const accessToken = doc.id;

    if (data.sessionPassword !== sessionPassword && data.isPrivate) {
      return res.status(401).json({ message: "Incorrect password for this session." });
    }

    return res.status(200).json({ message: accessToken });

  } catch (e) {
    console.error("Error verifying session:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};



/* Creating and Editing Panels (CRUD) */

export const createNewCommunityPanel = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.roomID;
  const accessToken = req.params.accessToken;

  const { x, y, z, r, g, b, alpha, panelID } = req.body || {};

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
  if (!roomID || !museumID || !panelID) {
    return res.status(400).json({ message: "Missing parameter. Either museumID, roomID, or panelID. Please check parameters." });
  }

  try {
    // Prepare the data to insert
    const panelData = {
      museumID,
      roomID,
      sessionID: accessToken,
      x,
      y,
      z,
      r,
      g,
      b,
      alpha,
      panelID,
      spotlight: false,
    };

    // Build a deterministic document ID to avoid duplicates
    const docID = `${museumID}_${roomID}_${accessToken}_${panelID}`;

    // Create or overwrite the document
    await db.collection("CommunityPanelData").doc(docID).set(panelData, { merge: false });

    return res.status(201).json({ message: `Panel ${panelID} created/updated. Document ID: ${docID}` });
  } catch (e) {
    console.error("Error creating/updating document:", e);
    return res.status(503).json({ message: "Server could not connect to the database." });
  }
};

export const getCommunityPanels = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.roomID;
  const accessToken = req.params.accessToken;

  try {
    // --- Get Curator panels (no sessionID) ---
    const curatorSnapshot = await db.collection("CuratorPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .get();

    let curatorPanels = await Promise.all(curatorSnapshot.docs.map(async (doc) => {
      const data = doc.data();
      const text = await getTextFieldFromPanelID(museumID, roomID, data.panelID);
      const longText = await getLongTextFieldFromPanelID(museumID, roomID, data.panelID);
      const icon = await getIconFieldFromPanelID(museumID, roomID, data.panelID);

      return {
        id: doc.id,
        ...data,
        text,
        longText,
        icon,
      };
    }));

    // --- Get Deleted curator panels for this session ---
    const deletedCuratorSnapshot = await db.collection("DeletedCommunityPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("sessionID", "==", accessToken)
      .get();

    const deletedCuratorPanelIDs = deletedCuratorSnapshot.docs.map(doc => doc.data().panelID);

    // --- Filter out deleted curator panels ---
    curatorPanels = curatorPanels.filter(panel => !deletedCuratorPanelIDs.includes(panel.panelID));

    // --- Get Community panels (with sessionID) ---
    const communitySnapshot = await db.collection("CommunityPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("sessionID", "==", accessToken)
      .get();

    const communityPanels = await Promise.all(communitySnapshot.docs.map(async (doc) => {
      const data = doc.data();
      const text = await getTextFieldFromPanelID(museumID, roomID, data.panelID);
      const longText = await getLongTextFieldFromPanelID(museumID, roomID, data.panelID);
      const icon = await getIconFieldFromPanelID(museumID, roomID, data.panelID);

      return {
        id: doc.id,
        ...data,
        text,
        longText,
        icon,
      };
    }));

    // --- Merge panels by panelID ---
    const panelMap = new Map();

    // First add curator panels (already filtered)
    curatorPanels.forEach(panel => {
      panelMap.set(panel.panelID, panel);
    });

    // Then overwrite with community panels (if same panelID exists)
    communityPanels.forEach(panel => {
      panelMap.set(panel.panelID, panel);
    });

    // Convert map back to array
    const mergedPanels = Array.from(panelMap.values());

    return res.status(200).json(mergedPanels);
  } catch (e) {
    console.error("Error getting documents:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};


export const getAvailableCommunityPanels = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.roomID;
  const sessionID = req.params.accessToken;

  try {
    // --- Get all panels for this museum/room ---
    const allPanelsSnapshot = await db.collection("PanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .get();

    const allPanels = allPanelsSnapshot.docs.map(doc => ({
      panelID: doc.data().panelID,
      title: doc.data().title,
      text: doc.data().text,
      longText: doc.data().longText,
      icon: doc.data().icon,
    }));

    // --- Get used panels from CuratorPanelData ---
    const curatorSnapshot = await db.collection("CuratorPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .get();

    let curatorPanelIDs = curatorSnapshot.docs.map(doc => doc.data().panelID);

    // --- Get deleted curator panels for this session ---
    const deletedCuratorSnapshot = await db.collection("DeletedCommunityPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("sessionID", "==", sessionID)
      .get();

    const deletedCuratorPanelIDs = deletedCuratorSnapshot.docs.map(doc => doc.data().panelID);

    // --- Filter out curator panels that were deleted in this session ---
    curatorPanelIDs = curatorPanelIDs.filter(panelID => !deletedCuratorPanelIDs.includes(panelID));

    // --- Get used panels from CommunityPanelData for this session ---
    const communitySnapshot = await db.collection("CommunityPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("sessionID", "==", sessionID)
      .get();

    const communityPanelIDs = communitySnapshot.docs.map(doc => doc.data().panelID);

    // --- Merge used IDs ---
    const usedPanelIDs = new Set([...curatorPanelIDs, ...communityPanelIDs]);

    // --- Filter out panels that are already used ---
    const availablePanels = allPanels.filter(panel => !usedPanelIDs.has(panel.panelID));

    return res.status(200).json(availablePanels);

  } catch (e) {
    console.error("Error getting documents:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};

export const deleteCommunityPanel = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.roomID;
  const sessionID = req.params.accessToken;
  const { panelID } = req.body || {}; 

  if (!panelID) {
    return res.status(400).json({ message: "panelID must be provided." });
  }

  try {
    // Delete specified doc from CommunityPanels using deterministic ID
    const docIDToDelete = `${museumID}_${roomID}_${sessionID}_${panelID}`;
    await db.collection("CommunityPanelData").doc(docIDToDelete).delete();

    // Add the panel to the deleted list to avoid the curatorPanel showing
    await db.collection("DeletedCommunityPanelData").add({
      museumID,
      roomID,
      sessionID,
      panelID
    });
    const deletedDocID = `${museumID}_${roomID}_${sessionID}_${panelID}`;
    await db.collection("DeletedCommunityPanelData").doc(deletedDocID).set(panelData, { merge: false });

    return res.status(200).json({ message: "Panel deleted successfully." });
  } catch (e) {
    console.error("Error deleting panel:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};

export const resetCommunitySessionPanels = async (req, res) => {
  const museumID = req.params.museumID;
  const roomID = req.params.roomID;
  const sessionID = req.params.accessToken;

  try {
    // --- Query DeletedCommunityPanelData ---
    const deletedSnapshot = await db.collection("DeletedCommunityPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("sessionID", "==", sessionID)
      .get();

    // Delete each doc
    const deletedDeletes = deletedSnapshot.docs.map(doc => doc.ref.delete());

    // --- Query CommunityPanelData ---
    const communitySnapshot = await db.collection("CommunityPanelData")
      .where("museumID", "==", museumID)
      .where("roomID", "==", roomID)
      .where("sessionID", "==", sessionID)
      .get();

    // Delete each doc
    const communityDeletes = communitySnapshot.docs.map(doc => doc.ref.delete());

    // --- Run all deletes in parallel ---
    await Promise.all([...deletedDeletes, ...communityDeletes]);

    return res.status(200).json({ message: "Session panels cleared successfully." });
  } catch (e) {
    console.error("Error clearing session panels:", e);
    return res.status(500).json({ message: "Server could not clear session panels." });
  }
};

