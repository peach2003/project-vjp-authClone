const Message = require("../models/message");

class ChatController {
  // Gửi tin nhắn
  async sendMessage(req, res) {
    try {
      const { sender, receiver, message, message_type } = req.body;

      if (!sender || !receiver || !message || !message_type) {
        return res.status(400).json({ error: "Thiếu thông tin tin nhắn" });
      }

      const result = await Message.create(
        sender,
        receiver,
        message,
        message_type
      );
      res.json({ message: "Tin nhắn đã được gửi", messageId: result.insertId });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi gửi tin nhắn" });
    }
  }

  // Lấy lịch sử chat
  async getChatHistory(req, res) {
    try {
      const { sender, receiver } = req.query;

      if (!sender || !receiver) {
        return res.status(400).json({ error: "Thiếu thông tin người dùng" });
      }

      const messages = await Message.getChatHistory(sender, receiver);
      res.json(messages);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy lịch sử chat" });
    }
  }

  // Đánh dấu tin nhắn đã xem
  async markAsSeen(req, res) {
    try {
      const { userId, chatPartnerId } = req.body;

      if (!userId || !chatPartnerId) {
        return res.status(400).json({ error: "Thiếu thông tin người dùng" });
      }

      await Message.markAsSeen(userId, chatPartnerId);
      res.json({ message: "Tin nhắn đã được đánh dấu là đã xem" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi đánh dấu tin nhắn đã xem" });
    }
  }

  // Xóa tin nhắn
  async deleteMessage(req, res) {
    try {
      const { messageId, userId } = req.body;

      if (!messageId || !userId) {
        return res
          .status(400)
          .json({ error: "Thiếu thông tin tin nhắn hoặc người dùng" });
      }

      const result = await Message.delete(messageId, userId);
      if (result.affectedRows === 0) {
        return res
          .status(403)
          .json({ error: "Bạn không thể xóa tin nhắn của người khác" });
      }

      res.json({ message: "Tin nhắn đã được xóa" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa tin nhắn" });
    }
  }

  // Chỉnh sửa tin nhắn
  async editMessage(req, res) {
    try {
      const { messageId, userId, newMessage } = req.body;

      if (!messageId || !userId || !newMessage) {
        return res
          .status(400)
          .json({ error: "Thiếu thông tin chỉnh sửa tin nhắn" });
      }

      const result = await Message.edit(messageId, userId, newMessage);
      if (result.affectedRows === 0) {
        return res
          .status(403)
          .json({ error: "Bạn không thể chỉnh sửa tin nhắn của người khác" });
      }

      res.json({ message: "Tin nhắn đã được chỉnh sửa" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi chỉnh sửa tin nhắn" });
    }
  }
}

module.exports = new ChatController();
