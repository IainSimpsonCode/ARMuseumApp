import { db } from "../firebaseAdmin.js";

export const getCommunitySessions = async (req, res) => {

  const museumID = req.params.museumID;

  if (!museumID) {
    return res.status(400).json({ message: "Missing parameter museumID." });
  }

  try {
    const snapshot = await db.collection("CommunitySessionData")
      .where("museumID", "==", museumID)
      .get();

    const sessions = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    const sessionIDs = sessions.map(session => session.sessionID);

    return res.status(200).json(sessionIDs);
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

    if (data.sessionPassword !== sessionPassword) {
      return res.status(401).json({ message: "Incorrect password for this session." });
    }

    return res.status(200).json({ accessToken: accessToken });

  } catch (e) {
    console.error("Error verifying session:", e);
    return res.status(500).json({ message: "Server could not connect to the database." });
  }
};
