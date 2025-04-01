require("dotenv").config();
const express = require("express");
const http = require("http"); // ✅ Import module HTTP
const socketIo = require("socket.io"); // ✅ Import socket.io
const mysql = require("mysql2");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const cors = require("cors");
const bodyParser = require("body-parser");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const cloudinary = require("./config");
const upload = multer({
  dest: "uploads/",
  limits: { fileSize: 5 * 1024 * 1024 }, // Giới hạn 5MB
});

const app = express();
const server = http.createServer(app); // ✅ Tạo server HTTP trước
const io = socketIo(server, {
  // ✅ Gắn socket.io vào server
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

app.use(cors());
app.use(bodyParser.json());

// Kết nối MySQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "auth_system",
});

db.connect((err) => {
  if (err) {
    console.error("❌ Lỗi kết nối MySQL:", err);
    return;
  }
  console.log("✅ Đã kết nối MySQL");
});

// 🔥 WebSocket: Lắng nghe sự kiện tin nhắn mới
io.on("connection", (socket) => {
  console.log("🟢 User connected:", socket.id);

  socket.on("sendMessage", ({ sender, receiver, message, message_type }) => {
    console.log(`📨 Tin nhắn từ ${sender} đến ${receiver}: "${message}"`);

    db.query(
      "INSERT INTO messages (sender, receiver, message, message_type) VALUES (?, ?, ?, ?)",
      [sender, receiver, message, message_type],
      (err, result) => {
        if (err) {
          console.error("❌ Lỗi khi gửi tin nhắn:", err);
          return;
        }

        // 🔥 Phát sự kiện tin nhắn mới đến người nhận
        io.emit(`newMessage-${receiver}`, {
          sender,
          receiver,
          message,
          message_type,
          created_at: new Date().toISOString(),
        });
      }
    );
  });

  socket.on("disconnect", () => {
    console.log("🔴 User disconnected:", socket.id);
  });
});

// Đăng ký tài khoản
app.post("/register", (req, res) => {
  const { username, password, role } = req.body;

  // Kiểm tra role hợp lệ
  const validRoles = ["doanh_nghiep", "chuyen_gia", "tu_van_vien", "operator"];
  if (!validRoles.includes(role)) {
    return res.status(400).json({ error: "Vai trò không hợp lệ" });
  }

  // Mã hóa mật khẩu trước khi lưu vào database
  bcrypt.hash(password, 10, (err, hash) => {
    if (err) return res.status(500).json({ error: "Lỗi mã hóa mật khẩu" });

    const sql =
      "INSERT INTO users (username, password, role, online) VALUES (?, ?, ?, false)";
    db.query(sql, [username, hash, role], (err, result) => {
      if (err)
        return res.status(400).json({ error: "Tên đăng nhập đã tồn tại" });

      res.json({ message: "Đăng ký thành công" });
    });
  });
});

// Đăng nhập
app.post("/login", (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT * FROM users WHERE username = ?";

  db.query(sql, [username], (err, results) => {
    if (err || results.length === 0) {
      console.log("❌ Lỗi: Không tìm thấy tài khoản!");
      return res.status(400).json({ error: "Tài khoản không tồn tại" });
    }

    bcrypt.compare(password, results[0].password, (err, match) => {
      if (!match) {
        console.log("❌ Lỗi: Mật khẩu không đúng!");
        return res.status(400).json({ error: "Mật khẩu không đúng" });
      }

      // ✅ Trả về userId đúng
      const userId = results[0].id;
      const role = results[0].role;

      // ✅ Cập nhật trạng thái online
      db.query(
        "UPDATE users SET online = true WHERE id = ?",
        [userId],
        (updateErr) => {
          if (updateErr) {
            console.log("❌ Lỗi cập nhật trạng thái online:", updateErr);
            return res
              .status(500)
              .json({ error: "Lỗi cập nhật trạng thái online" });
          }

          const token = jwt.sign(
            { id: userId, username, role, online: true }, // ✅ Đặt online = true trong token
            process.env.JWT_SECRET || "my_secret",
            { expiresIn: "1h" }
          );

          console.log(`✅ Đăng nhập thành công! User ID: ${userId}`);

          res.json({
            message: "Đăng nhập thành công",
            userId: userId,
            role: role,
            token: token,
            online: true, // ✅ Xác nhận user đang online
          });
        }
      );
    });
  });
});

app.post("/logout", (req, res) => {
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).json({ error: "Thiếu userId" });
  }

  // ✅ Cập nhật trạng thái online thành false
  db.query(
    "UPDATE users SET online = false WHERE id = ?",
    [userId],
    (err, result) => {
      if (err) {
        console.log("❌ Lỗi cập nhật trạng thái online:", err);
        return res
          .status(500)
          .json({ error: "Lỗi khi cập nhật trạng thái online" });
      }

      if (result.affectedRows === 0) {
        return res.status(400).json({ error: "UserId không tồn tại" });
      }

      console.log(`✅ User ID ${userId} đã đăng xuất (online = false)`);
      res.json({ message: "Đăng xuất thành công", online: false });
    }
  );
});

// Lấy danh sách người dùng
app.get("/users", (req, res) => {
  const sql = "SELECT id, username, role FROM users";
  db.query(sql, (err, results) => {
    if (err)
      return res.status(500).json({ error: "Lỗi lấy danh sách người dùng" });

    res.json(results);
  });
});

// Cập nhật quyền user (chỉ Operator mới có quyền thay đổi)
app.put("/update-role", (req, res) => {
  const { username, role } = req.body;

  const validRoles = ["doanh_nghiep", "chuyen_gia", "tu_van_vien", "operator"];
  if (!validRoles.includes(role)) {
    return res.status(400).json({ error: "Vai trò không hợp lệ" });
  }

  const sql = "UPDATE users SET role = ? WHERE username = ?";
  db.query(sql, [role, username], (err, result) => {
    if (err || result.affectedRows === 0) {
      return res.status(400).json({ error: "Lỗi khi cập nhật quyền" });
    }
    res.json({ message: "Cập nhật quyền thành công" });
  });
});

// CODE NGÀY 11/03/2025
app.post("/google-login", async (req, res) => {
  try {
    const { email, uid } = req.body;

    if (!email || !uid) {
      return res.status(400).json({ error: "Thiếu thông tin tài khoản" });
    }

    const sqlCheckUser = "SELECT * FROM users WHERE username = ?";
    db.query(sqlCheckUser, [email], async (err, results) => {
      if (err) {
        console.error("❌ Lỗi kiểm tra tài khoản:", err);
        return res.status(500).json({ error: "Lỗi kiểm tra tài khoản" });
      }

      if (results.length > 0) {
        // 🟢 Người dùng đã tồn tại, lấy thông tin từ database
        const userId = results[0].id; // ✅ Lấy userId từ kết quả truy vấn
        const role = results[0].role; // ✅ Lấy role từ database
        // 🟢 Người dùng đã tồn tại, lấy thông tin từ database
        console.log(`✅ User tồn tại: ${email}, Role: ${results[0].role}`);

        db.query("UPDATE users SET online = true WHERE id = ?", [userId]);

        const token = jwt.sign(
          { id: userId, username: email, role: results[0].role },
          process.env.JWT_SECRET || "my_secret",
          { expiresIn: "1h" }
        );

        return res.json({
          message: "Đăng nhập thành công",
          userId: userId, // ✅ Trả về userId
          token,
          role: results[0].role,
          online: true, // ✅ Trả về trạng thái online
        });
      } else {
        // 🔹 Người dùng mới, tạo tài khoản
        console.log(`🟢 Người dùng mới, tạo tài khoản: ${email}`);

        // Mã hóa UID làm mật khẩu ảo
        const hashedPassword = await bcrypt.hash(uid, 10);

        const sqlInsert =
          "INSERT INTO users (username, password, role, online) VALUES (?, ?, 'doanh_nghiep', false)";
        db.query(sqlInsert, [email, hashedPassword], (err, result) => {
          if (err) {
            console.error("❌ Lỗi tạo tài khoản:", err);
            return res.status(500).json({ error: "Lỗi tạo tài khoản mới" });
          }

          console.log("✅ Tạo tài khoản thành công!");
          const userId = result.insertId; // ✅ Lấy userId mới tạo
          const token = jwt.sign(
            { username: email, role: "doanh_nghiep" },
            process.env.JWT_SECRET || "my_secret",
            { expiresIn: "1h" }
          );

          return res.json({
            message: "Đăng nhập thành công",
            userId: userId, // ✅ Trả về userId mới tạo
            token,
            role: "doanh_nghiep",
            online: true, // ✅ Mặc định online = true khi đăng ký mới
          });
        });
      }
    });
  } catch (error) {
    console.error("❌ Lỗi trong quá trình xử lý:", error);
    res.status(500).json({ error: "Lỗi server" });
  }
});

//Gửi lời mời kết bạn
app.post("/friends/request", (req, res) => {
  const { fromUser, toUser } = req.body;
  console.log("🔹 Nhận yêu cầu kết bạn:", req.body); // Debug

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

//Chấp nhận lời mời kết bạn
app.post("/friends/accept", (req, res) => {
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
//Hủy lời mời kết bạn
app.post("/friends/reject", (req, res) => {
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
//Lấy danh sách lời mời kết bạn
app.get("/friends/pending/:userId", (req, res) => {
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

//Lấy danh sách bạn bè trừ user đăng nhập
app.get("/friends/list/:userId", (req, res) => {
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

//Lấy danh sách user trừ user đang nhập
app.get("/users/all/:userId", (req, res) => {
  const { userId } = req.params;

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
    if (err) return res.status(500).json({ error: "Lỗi database" });
    res.json(results);
  });
});

//Api gửi tin nhắn giữa 2 người
app.post("/chat/send", (req, res) => {
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

//API lấy lịch sử tin nhắn giữa 2 người
app.get("/chat/history", (req, res) => {
  const { sender, receiver } = req.query;

  if (!sender || !receiver) {
    return res.status(400).json({ error: "Thiếu thông tin người dùng" });
  }

  db.query(
    `SELECT sender, receiver, message, message_type, seen, created_at 
         FROM messages 
         WHERE (sender = ? AND receiver = ?) OR (sender = ? AND receiver = ?)
         ORDER BY created_at ASC`,
    [sender, receiver, receiver, sender],
    (err, results) => {
      if (err) {
        console.error("❌ Lỗi khi lấy lịch sử chat:", err);
        return res.status(500).json({ error: "Lỗi khi lấy lịch sử chat" });
      }
      res.json(results);
    }
  );
});

//API đánh dấu tin nhắn đã xem
app.post("/chat/seen", (req, res) => {
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

//API xóa một tin nhắn
app.post("/chat/delete", (req, res) => {
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

//API chỉnh sửa tin nhắn
app.post("/chat/edit", (req, res) => {
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

//Chat nhóm
// API tạo nhóm chat
app.post("/groups/create", (req, res) => {
  const { name, adminId } = req.body;

  if (!name || !adminId) {
    return res.status(400).json({ error: "Thiếu thông tin nhóm hoặc admin" });
  }

  // 🔍 Kiểm tra nhóm có tồn tại chưa
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

    // 🟢 Nếu chưa tồn tại, tiến hành tạo nhóm
    db.query("INSERT INTO groups (name) VALUES (?)", [name], (err, result) => {
      if (err) {
        console.error("❌ Lỗi khi tạo nhóm:", err);
        return res.status(500).json({ error: "Lỗi tạo nhóm" });
      }

      const groupId = result.insertId;
      console.log(`✅ Nhóm tạo thành công với ID: ${groupId}`);

      // 🔹 Thêm admin vào nhóm
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

//API gửi lời mời vào nhóm
app.post("/group/create", (req, res) => {
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

    // 🟢 Nếu chưa tồn tại, tiến hành tạo nhóm
    db.query("INSERT INTO groups (name) VALUES (?)", [name], (err, result) => {
      if (err) {
        console.error("❌ Lỗi khi tạo nhóm:", err);
        return res.status(500).json({ error: "Lỗi tạo nhóm" });
      }

      const groupId = result.insertId;
      console.log(`✅ Nhóm tạo thành công với ID: ${groupId}`);

      // 🔹 Thêm tất cả thành viên vào nhóm (bao gồm cả creator)
      const memberQueries = [...members, creatorId].map((userId) => {
        return new Promise((resolve, reject) => {
          db.query(
            "INSERT INTO group_members (group_id, user_id) VALUES (?, ?)",
            [groupId, userId],
            (err, result) => {
              if (err) {
                console.error(`❌ Lỗi khi thêm user ${userId} vào nhóm:`, err);
                reject(err);
              } else {
                resolve(result);
              }
            }
          );
        });
      });

      // ✅ Đợi tất cả thành viên được thêm vào nhóm
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

// API: Lấy danh sách nhóm của user
app.get("/groups/list/:userId", (req, res) => {
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

//API: Gửi tin nhắn trong nhóm
app.post("/group/send-message", (req, res) => {
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

//API lấy danh sách thành viên trong nhóm
app.get("/group/members/:groupId", (req, res) => {
  const { groupId } = req.params;

  db.query(
    `SELECT users.id, users.username 
       FROM group_members 
       JOIN users ON group_members.user_id = users.id
       WHERE group_members.group_id = ? AND group_members.status = 'accepted'`,
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

//API lấy lịch sử tin nhắn nhóm
app.get("/group/messages/:groupId", (req, res) => {
  const { groupId } = req.params;

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
        return res.status(500).json({ error: "Lỗi khi lấy tin nhắn nhóm" });
      }
      res.json(results);
    }
  );
});

///API gửi nhận file, video, ảnh trong  chat private
// ✅ API upload image
app.post("/upload/image", upload.single("file"), async (req, res) => {
  const filePath = req.file.path;
  const { sender, receiver } = req.body;

  if (!sender || !receiver) {
    return res.status(400).json({ error: "Thiếu thông tin sender/receiver" });
  }

  try {
    const result = await cloudinary.uploader.upload(filePath, {
      resource_type: "auto", // phân biệt video / image
    });

    const messageType = result.resource_type === "video" ? "video" : "image";
    const cloudUrl = result.secure_url;

    // ✅ Lưu vào bảng messages
    db.query(
      "INSERT INTO messages (sender, receiver, message, message_type) VALUES (?, ?, ?, ?)",
      [sender, receiver, cloudUrl, messageType],
      (err, resultDb) => {
        fs.unlinkSync(filePath); // xóa file tạm
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

// ✅ API upload file
// ✅ API upload file
app.post("/upload/file", upload.single("file"), async (req, res) => {
  const filePath = req.file.path;
  const { sender, receiver, original_file_name, file_extension } = req.body;

  if (!sender || !receiver) {
    return res.status(400).json({ error: "Thiếu thông tin sender/receiver" });
  }

  try {
    // Tạo tên file có đuôi để upload lên Cloudinary
    const fileNameWithExt = original_file_name || path.basename(filePath);

    // Upload lên Cloudinary với public_id có bao gồm đuôi file
    const result = await cloudinary.uploader.upload(filePath, {
      resource_type: "raw",
      public_id:
        fileNameWithExt.replace(/\.[^/.]+$/, "") + (file_extension || ""), // thêm đuôi file vào public_id
    });

    const cloudUrl = result.secure_url;

    // ✅ Lưu vào bảng messages (chỉ lưu thông tin cơ bản)
    db.query(
      "INSERT INTO messages (sender, receiver, message, message_type) VALUES (?, ?, ?, 'file')",
      [sender, receiver, cloudUrl],
      (err, resultDb) => {
        fs.unlinkSync(filePath); // xóa file tạm
        if (err) {
          console.error("❌ Lỗi lưu DB:", err);
          return res.status(500).json({ error: "Lỗi lưu tin nhắn" });
        }

        // Trả về cả thông tin file trong response để client có thể lưu vào state
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

// Khởi động server
const PORT = 3000;
app.listen(PORT, () =>
  console.log(`🚀 Server running on http://localhost:${PORT}`)
);
