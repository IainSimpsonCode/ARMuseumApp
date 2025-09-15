import express from "express";
import swaggerUi from "swagger-ui-express";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

import { getMuseumNames } from "./functions/MuseumData.js";
import { validateCuratorLogin } from "./functions/CuratorAuth.js";
import { createNewCuratorPanel, deleteCuratorPanel, getCuratorPanels, updateCuratorPanel } from "./functions/PanelData.js";
import { serverHealthCheck } from "./functions/healthCheck.js";
import { createCommunitySession, deleteCommunitySession, getCommunitySessions } from "./functions/communitySessions.js";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const swaggerPath = path.join(__dirname, "swagger.json");
const swaggerDocument = JSON.parse(fs.readFileSync(swaggerPath, "utf8"));

app.use("/api/docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.get("/api/museums", getMuseumNames);

app.post("/api/:museumID/authenticate", validateCuratorLogin)

app.get("/api/:museumID/:roomID/panel", getCuratorPanels)
app.post("/api/:museumID/:roomID/panel", createNewCuratorPanel)
app.patch("/api/:museumID/:roomID/panel", updateCuratorPanel)
app.delete("/api/:museumID/:roomID/panel", deleteCuratorPanel)

app.get("/api/:museumID/community", getCommunitySessions)
app.post("/api/:museumID/community", createCommunitySession)
app.delete("/api/:museumID/community", deleteCommunitySession)

app.get("/server/health", serverHealthCheck)

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
