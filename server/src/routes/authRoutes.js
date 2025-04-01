const express = require("express");
const router = express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const db = require("../config/database");

// Đăng ký tài khoản
router.post("/register", (req, res) => {
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
router.post("/login", (req, res) => {
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

      const userId = results[0].id;
      const role = results[0].role;

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
            { id: userId, username, role, online: true },
            process.env.JWT_SECRET || "my_secret",
            { expiresIn: "1h" }
          );

          console.log(`✅ Đăng nhập thành công! User ID: ${userId}`);

          res.json({
            message: "Đăng nhập thành công",
            userId: userId,
            role: role,
            token: token,
            online: true,
          });
        }
      );
    });
  });
});

// Đăng xuất
router.post("/logout", (req, res) => {
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).json({ error: "Thiếu userId" });
  }

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
router.get("/users", (req, res) => {
  const sql = "SELECT id, username, role FROM users";
  db.query(sql, (err, results) => {
    if (err)
      return res.status(500).json({ error: "Lỗi lấy danh sách người dùng" });

    res.json(results);
  });
});

// Cập nhật quyền user
router.put("/update-role", (req, res) => {
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

// Google login
router.post("/google-login", async (req, res) => {
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
        const userId = results[0].id;
        const role = results[0].role;
        console.log(`✅ User tồn tại: ${email}, Role: ${results[0].role}`);

        db.query("UPDATE users SET online = true WHERE id = ?", [userId]);

        const token = jwt.sign(
          { id: userId, username: email, role: results[0].role },
          process.env.JWT_SECRET || "my_secret",
          { expiresIn: "1h" }
        );

        return res.json({
          message: "Đăng nhập thành công",
          userId: userId,
          token,
          role: results[0].role,
          online: true,
        });
      } else {
        console.log(`🟢 Người dùng mới, tạo tài khoản: ${email}`);

        const hashedPassword = await bcrypt.hash(uid, 10);

        const sqlInsert =
          "INSERT INTO users (username, password, role, online) VALUES (?, ?, 'doanh_nghiep', false)";
        db.query(sqlInsert, [email, hashedPassword], (err, result) => {
          if (err) {
            console.error("❌ Lỗi tạo tài khoản:", err);
            return res.status(500).json({ error: "Lỗi tạo tài khoản mới" });
          }

          console.log("✅ Tạo tài khoản thành công!");
          const userId = result.insertId;
          const token = jwt.sign(
            { username: email, role: "doanh_nghiep" },
            process.env.JWT_SECRET || "my_secret",
            { expiresIn: "1h" }
          );

          return res.json({
            message: "Đăng nhập thành công",
            userId: userId,
            token,
            role: "doanh_nghiep",
            online: true,
          });
        });
      }
    });
  } catch (error) {
    console.error("❌ Lỗi trong quá trình xử lý:", error);
    res.status(500).json({ error: "Lỗi server" });
  }
});

// Lấy danh sách user có thể kết bạn
router.get("/users/all/:userId", (req, res) => {
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

module.exports = router;
