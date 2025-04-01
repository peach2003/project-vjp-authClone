const Friend = require("../models/friend");

class FriendController {
  // Gửi lời mời kết bạn
  async sendRequest(req, res) {
    try {
      const { fromUser, toUser } = req.body;

      if (!fromUser || !toUser) {
        return res.status(400).json({ error: "Thiếu thông tin người dùng" });
      }

      const hasPendingRequest = await Friend.checkPendingRequest(
        fromUser,
        toUser
      );
      if (hasPendingRequest) {
        return res.status(400).json({ error: "Lời mời kết bạn đã tồn tại" });
      }

      await Friend.sendRequest(fromUser, toUser);
      res.json({ message: "Lời mời kết bạn đã được gửi" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi gửi lời mời kết bạn" });
    }
  }

  // Chấp nhận lời mời kết bạn
  async acceptRequest(req, res) {
    try {
      const { fromUser, toUser } = req.body;

      if (!fromUser || !toUser) {
        return res.status(400).json({ error: "Thiếu thông tin người dùng" });
      }

      const result = await Friend.acceptRequest(fromUser, toUser);
      if (result.affectedRows === 0) {
        return res
          .status(400)
          .json({ error: "Lời mời kết bạn không tồn tại hoặc đã xử lý" });
      }

      res.json({ message: "Đã chấp nhận lời mời kết bạn" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi server" });
    }
  }

  // Từ chối lời mời kết bạn
  async rejectRequest(req, res) {
    try {
      const { fromUser, toUser } = req.body;

      if (!fromUser || !toUser) {
        return res.status(400).json({ error: "Thiếu thông tin người dùng" });
      }

      const result = await Friend.rejectRequest(fromUser, toUser);
      if (result.affectedRows === 0) {
        return res
          .status(400)
          .json({ error: "Không tìm thấy lời mời kết bạn" });
      }

      res.json({ message: "Đã từ chối lời mời kết bạn" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi server" });
    }
  }

  // Lấy danh sách lời mời kết bạn đang chờ
  async getPendingRequests(req, res) {
    try {
      const { userId } = req.params;
      const requests = await Friend.getPendingRequests(userId);
      res.json(requests);
    } catch (error) {
      res.status(500).json({ error: "Lỗi database" });
    }
  }

  // Lấy danh sách bạn bè
  async getFriendsList(req, res) {
    try {
      const { userId } = req.params;
      const friends = await Friend.getFriendsList(userId);
      res.json(friends);
    } catch (error) {
      res.status(500).json({ error: "Lỗi database" });
    }
  }

  // Lấy danh sách người dùng có thể kết bạn
  async getPotentialFriends(req, res) {
    try {
      const { userId } = req.params;
      const users = await Friend.getPotentialFriends(userId);
      res.json(users);
    } catch (error) {
      res.status(500).json({ error: "Lỗi database" });
    }
  }
}

module.exports = new FriendController();
