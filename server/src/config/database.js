const mysql = require("mysql2");

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

// Xử lý lỗi kết nối
db.on("error", (err) => {
  console.error("❌ Lỗi MySQL:", err);
  if (err.code === "PROTOCOL_CONNECTION_LOST") {
    console.log("🔄 Đang kết nối lại MySQL...");
    db.connect();
  } else {
    throw err;
  }
});

module.exports = db;
