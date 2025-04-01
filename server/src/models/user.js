const db = require("../config/database");

class User {
  // Tạo user mới
  static async create(username, password, role) {
    return new Promise((resolve, reject) => {
      db.query(
        "INSERT INTO users (username, password, role, online) VALUES (?, ?, ?, false)",
        [username, password, role],
        (err, result) => {
          if (err) reject(err);
          resolve(result);
        }
      );
    });
  }

  // Tìm user theo username
  static async findByUsername(username) {
    return new Promise((resolve, reject) => {
      db.query(
        "SELECT * FROM users WHERE username = ?",
        [username],
        (err, results) => {
          if (err) reject(err);
          resolve(results[0]);
        }
      );
    });
  }

  // Cập nhật trạng thái online
  static async updateOnlineStatus(userId, online) {
    return new Promise((resolve, reject) => {
      db.query(
        "UPDATE users SET online = ? WHERE id = ?",
        [online, userId],
        (err, result) => {
          if (err) reject(err);
          resolve(result);
        }
      );
    });
  }

  // Lấy tất cả user
  static async getAll() {
    return new Promise((resolve, reject) => {
      db.query("SELECT id, username, role FROM users", (err, results) => {
        if (err) reject(err);
        resolve(results);
      });
    });
  }

  // Cập nhật quyền user
  static async updateRole(username, role) {
    return new Promise((resolve, reject) => {
      db.query(
        "UPDATE users SET role = ? WHERE username = ?",
        [role, username],
        (err, result) => {
          if (err) reject(err);
          resolve(result);
        }
      );
    });
  }

  // Lấy danh sách user có thể kết bạn
  static async getPotentialUsers(userId) {
    return new Promise((resolve, reject) => {
      const sql = `
        SELECT users.id, users.username 
        FROM users
        WHERE users.id != ? 
        AND users.id NOT IN (
            SELECT friend_id FROM friends WHERE user_id = ? AND status = 'accepted'
            UNION
            SELECT user_id FROM friends WHERE friend_id = ? AND status = 'accepted'
        )
      `;

      db.query(sql, [userId, userId, userId], (err, results) => {
        if (err) reject(err);
        resolve(results);
      });
    });
  }
}

module.exports = User;
