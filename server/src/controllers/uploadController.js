const cloudinaryService = require("../services/cloudinaryService");
const Message = require("../models/message");
const fs = require("fs");
const path = require("path");

class UploadController {
  // Upload ảnh
  async uploadImage(req, res) {
    try {
      const filePath = req.file.path;
      const { sender, receiver } = req.body;

      if (!sender || !receiver) {
        return res
          .status(400)
          .json({ error: "Thiếu thông tin sender/receiver" });
      }

      const result = await cloudinaryService.uploadFile(filePath, {
        resource_type: "auto",
      });

      const messageType = result.resource_type === "video" ? "video" : "image";
      const cloudUrl = result.secure_url;

      const resultDb = await Message.create(
        sender,
        receiver,
        cloudUrl,
        messageType
      );
      fs.unlinkSync(filePath); // Xóa file tạm

      res.json({
        message: "Upload thành công",
        url: cloudUrl,
        message_type: messageType,
        messageId: resultDb.insertId,
      });
    } catch (error) {
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      res.status(500).json({ error: "Upload thất bại", detail: error });
    }
  }

  // Upload file
  async uploadFile(req, res) {
    try {
      const filePath = req.file.path;
      const { sender, receiver, original_file_name, file_extension } = req.body;

      if (!sender || !receiver) {
        return res
          .status(400)
          .json({ error: "Thiếu thông tin sender/receiver" });
      }

      const fileNameWithExt = original_file_name || path.basename(filePath);
      const result = await cloudinaryService.uploadFile(filePath, {
        resource_type: "raw",
        public_id:
          fileNameWithExt.replace(/\.[^/.]+$/, "") + (file_extension || ""),
      });

      const cloudUrl = result.secure_url;
      const resultDb = await Message.create(sender, receiver, cloudUrl, "file");
      fs.unlinkSync(filePath); // Xóa file tạm

      res.json({
        message: "Upload file thành công",
        url: cloudUrl,
        message_type: "file",
        messageId: resultDb.insertId,
        file_name: original_file_name,
        file_extension: file_extension,
      });
    } catch (error) {
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      res.status(500).json({ error: "Upload thất bại", detail: error });
    }
  }
}

module.exports = new UploadController();
