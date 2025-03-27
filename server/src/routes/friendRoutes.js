const express = require("express");
const router = express.Router();
const db = require("../config/database");

// Gửi lời mời kết bạn
router.post("/request", (req, res) => {
  const { fromUser, toUser } = req.body;
  console.log("🔹 Nhận yêu cầu kết bạn:", req.body);

  if (!fromUser || !toUser) {
    console.log("❌ Thiếu dữ liệu gửi lên!");
    return res.status(400).json({ error: "Thiếu thông tin người dùng" });
  }

  // Kiểm tra nếu lời mời đã tồn tại
  db.query(
    'SELECT * FROM friends WHERE user_id = ? AND friend_id = ? AND status = "pending"',
    [fromUser, toUser],
    (err, results) => {
      if (err) {
        console.log("❌ Lỗi DB:", err);
        return res.status(500).json({ error: "Lỗi database" });
      }

      if (results.length > 0) {
        console.log("❌ Lời mời đã tồn tại!");
        return res.status(400).json({ error: "Lời mời kết bạn đã tồn tại" });
      }

      // Thêm lời mời kết bạn
      db.query(
        'INSERT INTO friends (user_id, friend_id, status) VALUES (?, ?, "pending")',
        [fromUser, toUser],
        (err) => {
          if (err) {
            console.log("❌ Lỗi khi chèn vào database:", err);
            return res
              .status(500)
              .json({ error: "Lỗi khi gửi lời mời kết bạn" });
          }
          console.log("✅ Đã gửi lời mời kết bạn!");
          res.send({ message: "Lời mời kết bạn đã được gửi" });
        }
      );
    }
  );
});

// Chấp nhận lời mời kết bạn
router.post("/accept", (req, res) => {
  const { fromUser, toUser } = req.body;

  if (!fromUser || !toUser) {
    return res.status(400).json({ error: "Thiếu thông tin người dùng" });
  }

  db.query(
    'UPDATE friends SET status = "accepted" WHERE user_id = ? AND friend_id = ? AND status = "pending"',
    [fromUser, toUser],
    (err, result) => {
      if (err) return res.status(500).send(err);
      if (result.affectedRows === 0) {
        return res
          .status(400)
          .json({ error: "Lời mời kết bạn không tồn tại hoặc đã xử lý" });
      }
      res.send({ message: "Đã chấp nhận lời mời kết bạn" });
    }
  );
});

// Hủy lời mời kết bạn
router.post("/reject", (req, res) => {
  const { fromUser, toUser } = req.body;

  if (!fromUser || !toUser) {
    return res.status(400).json({ error: "Thiếu thông tin người dùng" });
  }

  db.query(
    'DELETE FROM friends WHERE user_id = ? AND friend_id = ? AND status = "pending"',
    [fromUser, toUser],
    (err, result) => {
      if (err) return res.status(500).send(err);
      if (result.affectedRows === 0) {
        return res
          .status(400)
          .json({ error: "Không tìm thấy lời mời kết bạn" });
      }
      res.send({ message: "Đã hủy lời mời kết bạn" });
    }
  );
});

// Lấy danh sách lời mời kết bạn
router.get("/pending/:userId", (req, res) => {
  const { userId } = req.params;

  db.query(
    'SELECT users.id, users.username FROM friends JOIN users ON friends.user_id = users.id WHERE friends.friend_id = ? AND friends.status = "pending"',
    [userId],
    (err, results) => {
      if (err) return res.status(500).json({ error: "Lỗi database" });

      res.json(results);
    }
  );
});

// Lấy danh sách bạn bè
router.get("/list/:userId", (req, res) => {
  const { userId } = req.params;

  db.query(
    `SELECT users.id, users.username, users.online FROM friends 
     JOIN users ON (friends.user_id = users.id OR friends.friend_id = users.id)
     WHERE (friends.user_id = ? OR friends.friend_id = ?) 
     AND friends.status = "accepted" AND users.id != ?`,
    [userId, userId, userId],
    (err, results) => {
      if (err) return res.status(500).json({ error: "Lỗi database" });
      res.json(results);
    }
  );
});

module.exports = router;
