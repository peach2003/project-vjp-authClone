const db = require("../config/database");

class Group {
  // Tạo nhóm mới với admin
  static async create(name, adminId) {
    return new Promise((resolve, reject) => {
      // Kiểm tra nhóm đã tồn tại chưa
      db.query(
        "SELECT id FROM groups WHERE name = ?",
        [name],
        (err, results) => {
          if (err) {
            console.error("❌ Lỗi khi kiểm tra nhóm:", err);
            return reject(err);
          }

          if (results.length > 0) {
            return reject(
              new Error("Tên nhóm đã tồn tại, vui lòng chọn tên khác")
            );
          }

          // Tạo nhóm mới
          db.query(
            "INSERT INTO groups (name) VALUES (?)",
            [name],
            (err, result) => {
              if (err) {
                console.error("❌ Lỗi khi tạo nhóm:", err);
                return reject(err);
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
                    return reject(err);
                  }
                  resolve(groupId);
                }
              );
            }
          );
        }
      );
    });
  }

  // Tạo nhóm mới với nhiều thành viên
  static async createWithMembers(name, members, creatorId) {
    return new Promise((resolve, reject) => {
      // Kiểm tra nhóm đã tồn tại chưa
      db.query(
        "SELECT id FROM groups WHERE name = ?",
        [name],
        (err, results) => {
          if (err) {
            console.error("❌ Lỗi khi kiểm tra nhóm:", err);
            return reject(err);
          }

          if (results.length > 0) {
            return reject(
              new Error("Tên nhóm đã tồn tại, vui lòng chọn tên khác")
            );
          }

          // Tạo nhóm mới
          db.query(
            "INSERT INTO groups (name) VALUES (?)",
            [name],
            (err, result) => {
              if (err) {
                console.error("❌ Lỗi khi tạo nhóm:", err);
                return reject(err);
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
                        console.error(
                          `❌ Lỗi khi thêm user ${userId} vào nhóm:`,
                          err
                        );
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
                .then(() => resolve(groupId))
                .catch(reject);
            }
          );
        }
      );
    });
  }

  // Lấy danh sách nhóm của user
  static async getUserGroups(userId) {
    return new Promise((resolve, reject) => {
      db.query(
        `SELECT g.id, g.name 
         FROM groups g 
         JOIN group_members gm ON g.id = gm.group_id 
         WHERE gm.user_id = ?`,
        [userId],
        (err, results) => {
          if (err) {
            console.error("❌ Lỗi khi lấy danh sách nhóm:", err);
            return reject(err);
          }
          resolve(results);
        }
      );
    });
  }

  // Gửi tin nhắn trong nhóm
  static async sendMessage(groupId, sender, message) {
    return new Promise((resolve, reject) => {
      db.query(
        "INSERT INTO group_messages (group_id, sender, message) VALUES (?, ?, ?)",
        [groupId, sender, message],
        (err, result) => {
          if (err) {
            console.error("❌ Lỗi khi gửi tin nhắn nhóm:", err);
            return reject(err);
          }
          resolve(result);
        }
      );
    });
  }

  // Lấy danh sách thành viên trong nhóm
  static async getMembers(groupId) {
    return new Promise((resolve, reject) => {
      db.query(
        `SELECT users.id, users.username 
         FROM group_members 
         JOIN users ON group_members.user_id = users.id
         WHERE group_members.group_id = ? AND group_members.status = 'accepted'`,
        [groupId],
        (err, results) => {
          if (err) {
            console.error("❌ Lỗi khi lấy danh sách thành viên:", err);
            return reject(err);
          }
          resolve(results);
        }
      );
    });
  }

  // Lấy lịch sử tin nhắn nhóm
  static async getMessages(groupId) {
    return new Promise((resolve, reject) => {
      db.query(
        `SELECT group_messages.*, users.username 
         FROM group_messages 
         JOIN users ON group_messages.sender = users.id
         WHERE group_id = ? 
         ORDER BY created_at ASC`,
        [groupId],
        (err, results) => {
          if (err) {
            console.error("❌ Lỗi khi lấy tin nhắn nhóm:", err);
            return reject(err);
          }
          resolve(results);
        }
      );
    });
  }
}

module.exports = Group;
