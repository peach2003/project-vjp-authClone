const cloudinary = require("../config/cloudinary");

class CloudinaryService {
  async uploadFile(filePath, options = {}) {
    try {
      const result = await cloudinary.uploader.upload(filePath, options);
      return result;
    } catch (error) {
      console.error("❌ Lỗi upload lên Cloudinary:", error);
      throw error;
    }
  }
}

module.exports = new CloudinaryService();
