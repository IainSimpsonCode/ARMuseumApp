import express from "express";
import swaggerUi from "swagger-ui-express";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

import { getMuseumNames } from "./functions/getMuseumNames.js";
import { validateCuratorLogin } from "./functions/curatorLogin.js";
import { createNewCuratorPanel, deleteCuratorPanel, getCuratorPanels, updateCuratorPanel } from "./functions/getPanelData.js";
import { serverHealthCheck } from "./functions/healthCheck.js";


const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const swaggerPath = path.join(__dirname, "swagger.json");
const swaggerDocument = JSON.parse(fs.readFileSync(swaggerPath, "utf8"));

app.use("/api/docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.get("/api/museums", getMuseumNames);

app.get("/api/:museumID/authenticate", validateCuratorLogin)

app.get("/api/:museumID/:roomID/panel", getCuratorPanels)
app.post("/api/:museumID/:roomID/panel", createNewCuratorPanel)
app.patch("/api/:museumID/:roomID/panel", updateCuratorPanel)
app.delete("/api/:museumID/:roomID/panel", deleteCuratorPanel)

app.get("/server/health", serverHealthCheck)

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
