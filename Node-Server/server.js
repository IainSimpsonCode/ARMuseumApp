import express from "express";
import swaggerUi from "swagger-ui-express";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

import { getMuseumNames, getRoomNames } from "./functions/MuseumData.js";
import { validateCuratorLogin } from "./functions/CuratorAuth.js";
import { createNewCuratorPanel, deleteCuratorPanel, getAllPanels, getAvailableCuratorPanels, getCuratorPanels, getPanelByID, updateCuratorPanel } from "./functions/PanelData.js";
import { serverHealthCheck } from "./functions/healthCheck.js";
import { createCommunitySession, createNewCommunityPanel, deleteCommunitySession, getCommunitySessions, joinCommunitySession } from "./functions/CommunitySessions.js";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const swaggerPath = path.join(__dirname, "swagger.json");
const swaggerDocument = JSON.parse(fs.readFileSync(swaggerPath, "utf8"));

app.use("/api/docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

/* Get all valid museumIDs and museum metadata */
app.get("/api/museums", getMuseumNames);
app.get("/api/:museumID/rooms", getRoomNames);

/* Check login details for a curator */
app.post("/api/:museumID/authenticate", validateCuratorLogin)

/* CRUD Functions for Creating Curator Panels */
app.get("/api/:museumID/:roomID/panel", getCuratorPanels)
app.post("/api/:museumID/:roomID/panel", createNewCuratorPanel)
app.patch("/api/:museumID/:roomID/panel", updateCuratorPanel)
app.delete("/api/:museumID/:roomID/panel", deleteCuratorPanel)

/* Get Panels from PanelData */
app.get("/api/:museumID/:roomID/allPanels", getAllPanels)
app.get("/api/:museumID/:roomID/curator/availablePanels", getAvailableCuratorPanels)
app.get("/api/:museumID/:roomID/community/:sessionID/availablePanels", getAvailableCuratorPanels)

app.get("/api/:museumID/:roomID/panel/:panelID", getPanelByID)

/* Creating/Joining Community Sessions */
app.get("/api/:museumID/community", getCommunitySessions)
app.post("/api/:museumID/community", createCommunitySession)
app.delete("/api/:museumID/community", deleteCommunitySession)
app.post("/api/:museumID/community/join", joinCommunitySession)

/* CRUD Functions for Creating Community Panels */
app.post("/api/:museumID/:roomID/community/:accessToken/panel", createNewCommunityPanel)

/* Check server is running. Either returns 200 or nothing */
app.get("/server/health", serverHealthCheck)

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
