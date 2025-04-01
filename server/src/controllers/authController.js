const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const User = require("../models/user");

class AuthController {
  // Đăng ký tài khoản
  async register(req, res) {
    try {
      const { username, password, role } = req.body;

      // Kiểm tra role hợp lệ
      const validRoles = [
        "doanh_nghiep",
        "chuyen_gia",
        "tu_van_vien",
        "operator",
      ];
      if (!validRoles.includes(role)) {
        return res.status(400).json({ error: "Vai trò không hợp lệ" });
      }

      // Mã hóa mật khẩu
      const hashedPassword = await bcrypt.hash(password, 10);

      // Tạo user mới
      const result = await User.create(username, hashedPassword, role);
      res.json({ message: "Đăng ký thành công" });
    } catch (error) {
      res.status(400).json({ error: "Tên đăng nhập đã tồn tại" });
    }
  }

  // Đăng nhập
  async login(req, res) {
    try {
      const { username, password } = req.body;
      const user = await User.findByUsername(username);

      if (!user) {
        return res.status(400).json({ error: "Tài khoản không tồn tại" });
      }

      const match = await bcrypt.compare(password, user.password);
      if (!match) {
        return res.status(400).json({ error: "Mật khẩu không đúng" });
      }

      // Cập nhật trạng thái online
      await User.updateOnlineStatus(user.id, true);

      // Tạo token
      const token = jwt.sign(
        { id: user.id, username: user.username, role: user.role, online: true },
        process.env.JWT_SECRET || "my_secret",
        { expiresIn: "1h" }
      );

      res.json({
        message: "Đăng nhập thành công",
        userId: user.id,
        role: user.role,
        token,
        online: true,
      });
    } catch (error) {
      res.status(500).json({ error: "Lỗi server" });
    }
  }

  // Đăng xuất
  async logout(req, res) {
    try {
      const { userId } = req.body;

      if (!userId) {
        return res.status(400).json({ error: "Thiếu userId" });
      }

      await User.updateOnlineStatus(userId, false);
      res.json({ message: "Đăng xuất thành công", online: false });
    } catch (error) {
      res.status(500).json({ error: "Lỗi server" });
    }
  }

  // Đăng nhập bằng Google
  async googleLogin(req, res) {
    try {
      const { email, uid } = req.body;

      if (!email || !uid) {
        return res.status(400).json({ error: "Thiếu thông tin tài khoản" });
      }

      let user = await User.findByUsername(email);

      if (!user) {
        // Tạo tài khoản mới nếu chưa tồn tại
        const hashedPassword = await bcrypt.hash(uid, 10);
        const result = await User.create(email, hashedPassword, "doanh_nghiep");
        user = { id: result.insertId, username: email, role: "doanh_nghiep" };
      }

      // Cập nhật trạng thái online
      await User.updateOnlineStatus(user.id, true);

      // Tạo token
      const token = jwt.sign(
        { id: user.id, username: user.username, role: user.role },
        process.env.JWT_SECRET || "my_secret",
        { expiresIn: "1h" }
      );

      res.json({
        message: "Đăng nhập thành công",
        userId: user.id,
        token,
        role: user.role,
        online: true,
      });
    } catch (error) {
      res.status(500).json({ error: "Lỗi server" });
    }
  }

  // Lấy danh sách người dùng
  async getUsers(req, res) {
    try {
      const users = await User.getAll();
      res.json(users);
    } catch (error) {
      res.status(500).json({ error: "Lỗi lấy danh sách người dùng" });
    }
  }

  // Cập nhật quyền user
  async updateRole(req, res) {
    try {
      const { username, role } = req.body;

      const validRoles = [
        "doanh_nghiep",
        "chuyen_gia",
        "tu_van_vien",
        "operator",
      ];
      if (!validRoles.includes(role)) {
        return res.status(400).json({ error: "Vai trò không hợp lệ" });
      }

      const result = await User.updateRole(username, role);
      if (result.affectedRows === 0) {
        return res.status(400).json({ error: "Lỗi khi cập nhật quyền" });
      }

      res.json({ message: "Cập nhật quyền thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi server" });
    }
  }

  // Lấy danh sách user trừ user đang nhập
  async getPotentialUsers(req, res) {
    try {
      const { userId } = req.params;
      const users = await User.getPotentialUsers(userId);
      res.json(users);
    } catch (error) {
      res.status(500).json({ error: "Lỗi database" });
    }
  }
}

module.exports = new AuthController();
