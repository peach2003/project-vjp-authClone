require("dotenv").config();
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const cloudinary = require("./config");

// Cấu hình multer
const upload = multer({
  dest: "uploads/",
  limits: { fileSize: 5 * 1024 * 1024 }, // Giới hạn 5MB
});

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Routes
app.use("/", require("./src/routes/authRoutes"));
app.use("/chat", require("./src/routes/chatRoutes"));
app.use("/friends", require("./src/routes/friendRoutes"));
app.use("/", require("./src/routes/groupRoutes"));
app.use("/upload", require("./src/routes/uploadRoutes"));
app.use("/upload", require("./src/routes/groupUploadRoutes"));

// Khởi động server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
