const Group = require("../models/group");

class GroupController {
  // Tạo nhóm chat mới
  async createGroup(req, res) {
    try {
      const { name, adminId } = req.body;

      if (!name || !adminId) {
        return res
          .status(400)
          .json({ error: "Thiếu thông tin nhóm hoặc admin" });
      }

      const groupId = await Group.create(name, adminId);
      res.json({
        message: "Nhóm đã được tạo",
        groupId: groupId,
      });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tạo nhóm" });
    }
  }

  // Tạo nhóm với nhiều thành viên
  async createGroupWithMembers(req, res) {
    try {
      const { name, members, creatorId } = req.body;

      if (
        !name ||
        !creatorId ||
        !Array.isArray(members) ||
        members.length === 0
      ) {
        return res
          .status(400)
          .json({ error: "Thiếu thông tin nhóm hoặc thành viên" });
      }

      const groupId = await Group.createWithMembers(name, members, creatorId);
      res.json({
        message: "Nhóm đã được tạo và thêm thành viên thành công",
        groupId,
      });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tạo nhóm" });
    }
  }

  // Lấy danh sách nhóm của user
  async getUserGroups(req, res) {
    try {
      const { userId } = req.params;
      const groups = await Group.getUserGroups(userId);
      res.json(groups);
    } catch (error) {
      res.status(500).json({ error: "Lỗi server" });
    }
  }

  // Gửi tin nhắn trong nhóm
  async sendGroupMessage(req, res) {
    try {
      const { groupId, sender, message } = req.body;

      if (!groupId || !sender || !message) {
        return res.status(400).json({ error: "Thiếu thông tin" });
      }

      const result = await Group.sendMessage(groupId, sender, message);
      res.json({ message: "Tin nhắn đã được gửi", messageId: result.insertId });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi gửi tin nhắn nhóm" });
    }
  }

  // Lấy danh sách thành viên trong nhóm
  async getGroupMembers(req, res) {
    try {
      const { groupId } = req.params;
      const members = await Group.getMembers(groupId);
      res.json(members);
    } catch (error) {
      res.status(500).json({ error: "Lỗi server" });
    }
  }

  // Lấy lịch sử tin nhắn nhóm
  async getGroupMessages(req, res) {
    try {
      const { groupId } = req.params;
      const messages = await Group.getMessages(groupId);
      res.json(messages);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy tin nhắn nhóm" });
    }
  }
}

module.exports = new GroupController();
