const db = require("../config/database");

class GroupMessage {
  static create(groupId, sender, message, messageType = "text") {
    return new Promise((resolve, reject) => {
      db.query(
        "INSERT INTO group_messages (group_id, sender, message, message_type) VALUES (?, ?, ?, ?)",
        [groupId, sender, message, messageType],
        (err, result) => {
          if (err) {
            console.error("❌ Lỗi tạo tin nhắn nhóm:", err);
            reject(err);
          } else {
            resolve(result);
          }
        }
      );
    });
  }

  static async getMessages(groupId, page = 1, limit = 10) {
    try {
      const offset = (page - 1) * limit;

      // Lấy tổng số tin nhắn
      const [countResult] = await new Promise((resolve, reject) => {
        db.query(
          "SELECT COUNT(*) as total FROM group_messages WHERE group_id = ?",
          [groupId],
          (err, result) => {
            if (err) reject(err);
            else resolve(result);
          }
        );
      });

      const total = parseInt(countResult?.total) || 0;
      const totalPages = Math.ceil(total / limit);

      // Lấy tin nhắn với phân trang
      const messages = await new Promise((resolve, reject) => {
        db.query(
          `SELECT gm.id, gm.group_id, gm.sender, gm.message, gm.message_type, 
                  gm.created_at, u.username as sender_name
           FROM group_messages gm
           JOIN users u ON gm.sender = u.id
           WHERE gm.group_id = ?
           ORDER BY gm.created_at DESC
           LIMIT ? OFFSET ?`,
          [groupId, limit, offset],
          (err, results) => {
            if (err) reject(err);
            else resolve(results);
          }
        );
      });

      return {
        messages,
        pagination: {
          currentPage: page,
          totalPages,
          totalMessages: total,
          messagesPerPage: limit,
        },
      };
    } catch (error) {
      throw error;
    }
  }
}

module.exports = GroupMessage;
