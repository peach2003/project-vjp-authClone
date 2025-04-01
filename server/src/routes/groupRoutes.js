const express = require("express");
const router = express.Router();
const db = require("../config/database");
const GroupMessage = require("../models/groupMessage");

// API tạo nhóm chat
router.post("/create", (req, res) => {
  const { name, adminId } = req.body;

  if (!name || !adminId) {
    return res.status(400).json({ error: "Thiếu thông tin nhóm hoặc admin" });
  }

  // Kiểm tra nhóm có tồn tại chưa
  db.query("SELECT id FROM groups WHERE name = ?", [name], (err, results) => {
    if (err) {
      console.error("❌ Lỗi khi kiểm tra nhóm:", err);
      return res.status(500).json({ error: "Lỗi kiểm tra nhóm" });
    }

    if (results.length > 0) {
      return res
        .status(400)
        .json({ error: "Tên nhóm đã tồn tại, vui lòng chọn tên khác" });
    }

    // Tạo nhóm mới
    db.query("INSERT INTO groups (name) VALUES (?)", [name], (err, result) => {
      if (err) {
        console.error("❌ Lỗi khi tạo nhóm:", err);
        return res.status(500).json({ error: "Lỗi tạo nhóm" });
      }

      const groupId = result.insertId;
      console.log(`✅ Nhóm tạo thành công với ID: ${groupId}`);

      // Thêm admin vào nhóm
      db.query(
        "INSERT INTO group_members (group_id, user_id) VALUES (?, ?)",
        [groupId, adminId],
        (err) => {
          if (err) {
            console.error("❌ Lỗi khi thêm admin vào nhóm:", err);
            return res
              .status(500)
              .json({ error: "Lỗi khi thêm admin vào nhóm" });
          }

          res.json({ message: "Nhóm đã được tạo", groupId: groupId });
        }
      );
    });
  });
});

// API tạo nhóm với nhiều thành viên
router.post("/group/create", (req, res) => {
  const { name, members, creatorId } = req.body;

  if (!name || !creatorId || !Array.isArray(members) || members.length === 0) {
    return res
      .status(400)
      .json({ error: "Thiếu thông tin nhóm hoặc thành viên" });
  }

  // Kiểm tra xem nhóm đã tồn tại chưa
  db.query("SELECT id FROM groups WHERE name = ?", [name], (err, results) => {
    if (err) {
      console.error("❌ Lỗi khi kiểm tra nhóm:", err);
      return res.status(500).json({ error: "Lỗi kiểm tra nhóm" });
    }

    if (results.length > 0) {
      return res
        .status(400)
        .json({ error: "Tên nhóm đã tồn tại, vui lòng chọn tên khác" });
    }

    // Tạo nhóm mới
    db.query("INSERT INTO groups (name) VALUES (?)", [name], (err, result) => {
      if (err) {
        console.error("❌ Lỗi khi tạo nhóm:", err);
        return res.status(500).json({ error: "Lỗi tạo nhóm" });
      }

      const groupId = result.insertId;
      console.log(`✅ Nhóm tạo thành công với ID: ${groupId}`);

      // Thêm tất cả thành viên vào nhóm
      const memberQueries = [...members, creatorId].map((userId) => {
        return new Promise((resolve, reject) => {
          db.query(
            "INSERT INTO group_members (group_id, user_id) VALUES (?, ?)",
            [groupId, userId],
            (err) => {
              if (err) {
                console.error(`❌ Lỗi khi thêm user ${userId} vào nhóm:`, err);
                reject(err);
              } else {
                resolve();
              }
            }
          );
        });
      });

      // Đợi tất cả thành viên được thêm vào
      Promise.all(memberQueries)
        .then(() => {
          res.json({
            message: "Nhóm đã được tạo và thêm thành viên thành công",
            groupId,
          });
        })
        .catch((err) => {
          res.status(500).json({ error: "Lỗi khi thêm thành viên vào nhóm" });
        });
    });
  });
});

// API lấy danh sách nhóm của user
router.get("/groups/list/:userId", (req, res) => {
  const { userId } = req.params;

  db.query(
    `SELECT g.id, g.name 
     FROM groups g 
     JOIN group_members gm ON g.id = gm.group_id 
     WHERE gm.user_id = ?`,
    [userId],
    (err, results) => {
      if (err) {
        console.error("❌ Lỗi khi lấy danh sách nhóm:", err);
        return res.status(500).json({ error: "Lỗi server" });
      }
      res.json(results);
    }
  );
});

// API gửi tin nhắn trong nhóm
router.post("/group/send-message", (req, res) => {
  const { groupId, sender, message } = req.body;

  if (!groupId || !sender || !message) {
    return res.status(400).json({ error: "Thiếu thông tin" });
  }

  db.query(
    "INSERT INTO group_messages (group_id, sender, message) VALUES (?, ?, ?)",
    [groupId, sender, message],
    (err, result) => {
      if (err) {
        console.error("❌ Lỗi khi gửi tin nhắn nhóm:", err);
        return res.status(500).json({ error: "Lỗi khi gửi tin nhắn nhóm" });
      }
      res.json({ message: "Tin nhắn đã được gửi", messageId: result.insertId });
    }
  );
});

// API lấy danh sách thành viên trong nhóm
router.get("/group/members/:groupId", (req, res) => {
  const { groupId } = req.params;

  db.query(
    `SELECT users.id, users.username 
     FROM group_members 
     JOIN users ON group_members.user_id = users.id
     WHERE group_members.group_id = ?`,
    [groupId],
    (err, results) => {
      if (err) {
        console.error("❌ Lỗi khi lấy danh sách thành viên:", err);
        return res.status(500).json({ error: "Lỗi server" });
      }

      res.json(results);
    }
  );
});

// API lấy lịch sử tin nhắn nhóm
router.get("/group/messages/:groupId", async (req, res) => {
  try {
    const { groupId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    if (!groupId) {
      return res.status(400).json({ error: "Thiếu thông tin nhóm" });
    }

    const result = await GroupMessage.getMessages(groupId, page, limit);
    res.json(result);
  } catch (error) {
    return res.status(500).json({ error: "Lỗi khi lấy lịch sử chat nhóm" });
  }
});

module.exports = router;
