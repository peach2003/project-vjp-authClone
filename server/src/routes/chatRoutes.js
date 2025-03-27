const express = require("express");
const router = express.Router();
const db = require("../config/database");

// Gửi tin nhắn
router.post("/send", (req, res) => {
  const { sender, receiver, message, message_type } = req.body;

  if (!sender || !receiver || !message || !message_type) {
    return res.status(400).json({ error: "Thiếu thông tin tin nhắn" });
  }

  db.query(
    "INSERT INTO messages (sender, receiver, message, message_type) VALUES (?, ?, ?, ?)",
    [sender, receiver, message, message_type],
    (err, result) => {
      if (err) {
        console.error("❌ Lỗi khi gửi tin nhắn:", err);
        return res.status(500).json({ error: "Lỗi khi gửi tin nhắn" });
      }
      console.log(`✅ Tin nhắn từ ${sender} đến ${receiver}: "${message}"`);
      res.json({ message: "Tin nhắn đã được gửi", messageId: result.insertId });
    }
  );
});

// Lấy lịch sử tin nhắn
router.get("/history", (req, res) => {
  try {
    const sender = parseInt(req.query.sender);
    const receiver = parseInt(req.query.receiver);
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    if (!sender || !receiver || isNaN(sender) || isNaN(receiver)) {
      return res.status(400).json({
        error: "Thiếu thông tin người dùng hoặc định dạng không hợp lệ",
      });
    }

    // Lấy tổng số tin nhắn
    const countQuery = `
      SELECT COUNT(*) as total 
      FROM messages 
      WHERE (sender = ? AND receiver = ?) 
      OR (sender = ? AND receiver = ?)
    `;

    db.query(
      countQuery,
      [sender, receiver, receiver, sender],
      (err, countResult) => {
        if (err) {
          return res.status(500).json({ error: "Lỗi khi lấy lịch sử chat" });
        }

        const total = parseInt(countResult[0]?.total) || 0;
        const totalPages = Math.ceil(total / limit);

        // Lấy tin nhắn với phân trang
        const messagesQuery = `
        SELECT id, sender, receiver, message, message_type, seen, created_at 
        FROM messages 
        WHERE (sender = ? AND receiver = ?) 
        OR (sender = ? AND receiver = ?)
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
      `;

        db.query(
          messagesQuery,
          [sender, receiver, receiver, sender, limit, offset],
          (err, results) => {
            if (err) {
              return res
                .status(500)
                .json({ error: "Lỗi khi lấy lịch sử chat" });
            }

            return res.json({
              messages: results || [],
              pagination: {
                currentPage: page,
                totalPages: totalPages,
                totalMessages: total,
                messagesPerPage: limit,
              },
            });
          }
        );
      }
    );
  } catch (error) {
    return res.status(500).json({ error: "Lỗi khi lấy lịch sử chat" });
  }
});

// Đánh dấu tin nhắn đã xem
router.post("/seen", (req, res) => {
  const { userId, chatPartnerId } = req.body;

  if (!userId || !chatPartnerId) {
    return res.status(400).json({ error: "Thiếu thông tin người dùng" });
  }

  db.query(
    "UPDATE messages SET seen = TRUE WHERE receiver = ? AND sender = ?",
    [userId, chatPartnerId],
    (err, result) => {
      if (err) {
        console.error("❌ Lỗi khi đánh dấu tin nhắn đã xem:", err);
        return res
          .status(500)
          .json({ error: "Lỗi khi đánh dấu tin nhắn đã xem" });
      }
      res.json({ message: "Tin nhắn đã được đánh dấu là đã xem" });
    }
  );
});

// Xóa tin nhắn
router.post("/delete", (req, res) => {
  const { messageId, userId } = req.body;

  if (!messageId || !userId) {
    return res
      .status(400)
      .json({ error: "Thiếu thông tin tin nhắn hoặc người dùng" });
  }

  db.query(
    "DELETE FROM messages WHERE id = ? AND sender = ?",
    [messageId, userId],
    (err, result) => {
      if (err) {
        console.error("❌ Lỗi khi xóa tin nhắn:", err);
        return res.status(500).json({ error: "Lỗi khi xóa tin nhắn" });
      }
      if (result.affectedRows === 0) {
        return res
          .status(403)
          .json({ error: "Bạn không thể xóa tin nhắn của người khác" });
      }
      res.json({ message: "Tin nhắn đã được xóa" });
    }
  );
});

// Chỉnh sửa tin nhắn
router.post("/edit", (req, res) => {
  const { messageId, userId, newMessage } = req.body;

  if (!messageId || !userId || !newMessage) {
    return res
      .status(400)
      .json({ error: "Thiếu thông tin chỉnh sửa tin nhắn" });
  }

  db.query(
    "UPDATE messages SET message = ? WHERE id = ? AND sender = ?",
    [newMessage, messageId, userId],
    (err, result) => {
      if (err) {
        console.error("❌ Lỗi khi chỉnh sửa tin nhắn:", err);
        return res.status(500).json({ error: "Lỗi khi chỉnh sửa tin nhắn" });
      }
      if (result.affectedRows === 0) {
        return res
          .status(403)
          .json({ error: "Bạn không thể chỉnh sửa tin nhắn của người khác" });
      }
      res.json({ message: "Tin nhắn đã được chỉnh sửa" });
    }
  );
});

module.exports = router;
