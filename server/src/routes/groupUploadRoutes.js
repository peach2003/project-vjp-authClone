const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const cloudinary = require("../config/cloudinary");
const db = require("../config/database");

// Cấu hình multer
const upload = multer({
  dest: "uploads/",
  limits: { fileSize: 5 * 1024 * 1024 }, // Giới hạn 5MB
});

// Upload image cho group chat
router.post("/group/image", upload.single("file"), async (req, res) => {
  const filePath = req.file.path;
  const { sender, groupId } = req.body;

  if (!sender || !groupId) {
    return res.status(400).json({ error: "Thiếu thông tin sender/groupId" });
  }

  try {
    const result = await cloudinary.uploader.upload(filePath, {
      resource_type: "auto",
    });

    const messageType = result.resource_type === "video" ? "video" : "image";
    const cloudUrl = result.secure_url;

    db.query(
      "INSERT INTO group_messages (group_id, sender, message, message_type) VALUES (?, ?, ?, ?)",
      [groupId, sender, cloudUrl, messageType],
      (err, resultDb) => {
        fs.unlinkSync(filePath);
        if (err) {
          console.error("❌ Lỗi lưu DB:", err);
          return res.status(500).json({ error: "Lỗi lưu tin nhắn" });
        }

        return res.json({
          message: "Upload thành công",
          url: cloudUrl,
          message_type: messageType,
          messageId: resultDb.insertId,
        });
      }
    );
  } catch (error) {
    console.error("❌ Upload lỗi:", error);
    fs.unlinkSync(filePath);
    res.status(500).json({ error: "Upload thất bại", detail: error });
  }
});

// Upload file cho group chat
router.post("/group/file", upload.single("file"), async (req, res) => {
  const filePath = req.file.path;
  const { sender, groupId, original_file_name, file_extension } = req.body;

  if (!sender || !groupId) {
    return res.status(400).json({ error: "Thiếu thông tin sender/groupId" });
  }

  try {
    const fileNameWithExt = original_file_name || path.basename(filePath);

    const result = await cloudinary.uploader.upload(filePath, {
      resource_type: "raw",
      public_id:
        fileNameWithExt.replace(/\.[^/.]+$/, "") + (file_extension || ""),
    });

    const cloudUrl = result.secure_url;

    db.query(
      "INSERT INTO group_messages (group_id, sender, message, message_type) VALUES (?, ?, ?, 'file')",
      [groupId, sender, cloudUrl],
      (err, resultDb) => {
        fs.unlinkSync(filePath);
        if (err) {
          console.error("❌ Lỗi lưu DB:", err);
          return res.status(500).json({ error: "Lỗi lưu tin nhắn" });
        }

        return res.json({
          message: "Upload file thành công",
          url: cloudUrl,
          message_type: "file",
          messageId: resultDb.insertId,
          file_name: original_file_name,
          file_extension: file_extension,
        });
      }
    );
  } catch (error) {
    console.error("❌ Upload lỗi:", error);
    fs.unlinkSync(filePath);
    res.status(500).json({ error: "Upload thất bại", detail: error });
  }
});

module.exports = router;
