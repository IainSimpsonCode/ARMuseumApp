import admin from "firebase-admin";
import dotenv from "dotenv";
import fs from "fs";

dotenv.config();

// If you’re using a service account key JSON file
const serviceAccount = JSON.parse(
  fs.readFileSync("./serviceAccountKey.json", "utf8")
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: process.env.STORAGEBUCKET
});

const db = admin.firestore();
const storage = admin.storage();

export { admin, db, storage };
