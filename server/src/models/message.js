const db = require("../config/database");

class Message {
  static create(sender, receiver, message, messageType) {
    return new Promise((resolve, reject) => {
      db.query(
        "INSERT INTO messages (sender, receiver, message, message_type) VALUES (?, ?, ?, ?)",
        [sender, receiver, message, messageType],
        (err, result) => {
          if (err) {
            console.error("❌ Lỗi tạo tin nhắn:", err);
            reject(err);
          } else {
            resolve(result);
          }
        }
      );
    });
  }

  static getChatHistory(sender, receiver, page = 1, limit = 10) {
    return new Promise((resolve, reject) => {
      const offset = (page - 1) * limit;

      db.query(
        `SELECT m.*, 
                u1.username as sender_username,
                u2.username as receiver_username
         FROM messages m
         JOIN users u1 ON m.sender = u1.id
         JOIN users u2 ON m.receiver = u2.id
         WHERE (m.sender = ? AND m.receiver = ?) 
         OR (m.sender = ? AND m.receiver = ?)
         ORDER BY m.created_at DESC
         LIMIT ? OFFSET ?`,
        [sender, receiver, receiver, sender, limit, offset],
        (err, results) => {
          if (err) {
            console.error("❌ Lỗi lấy lịch sử chat:", err);
            reject(err);
          } else {
            resolve(results);
          }
        }
      );
    });
  }

  static markAsSeen(userId, chatPartnerId) {
    return new Promise((resolve, reject) => {
      db.query(
        "UPDATE messages SET seen = TRUE WHERE receiver = ? AND sender = ?",
        [userId, chatPartnerId],
        (err, result) => {
          if (err) {
            console.error("❌ Lỗi đánh dấu tin nhắn đã xem:", err);
            reject(err);
          } else {
            resolve(result);
          }
        }
      );
    });
  }

  static delete(messageId, userId) {
    return new Promise((resolve, reject) => {
      db.query(
        "DELETE FROM messages WHERE id = ? AND sender = ?",
        [messageId, userId],
        (err, result) => {
          if (err) {
            console.error("❌ Lỗi xóa tin nhắn:", err);
            reject(err);
          } else {
            resolve(result);
          }
        }
      );
    });
  }

  static edit(messageId, userId, newMessage) {
    return new Promise((resolve, reject) => {
      db.query(
        "UPDATE messages SET message = ? WHERE id = ? AND sender = ?",
        [newMessage, messageId, userId],
        (err, result) => {
          if (err) {
            console.error("❌ Lỗi chỉnh sửa tin nhắn:", err);
            reject(err);
          } else {
            resolve(result);
          }
        }
      );
    });
  }
}

module.exports = Message;
