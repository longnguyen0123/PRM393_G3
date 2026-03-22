import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import User from "../models/users.js";
import { JWT_EXPIRES_IN, JWT_SECRET } from "../config/jwt.js";

export const login = async (req, res, next) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: "Username và password là bắt buộc",
      });
    }

    // .lean() trả về plain object, tránh lỗi Cast khi _id trong DB là string (vd: "user_admin")
    const user = await User.findOne({ username: username.trim() }).lean();
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Tên đăng nhập hoặc mật khẩu không đúng",
      });
    }

    if (user.status !== "ACTIVE") {
      return res.status(403).json({
        success: false,
        message: "Tài khoản đã bị vô hiệu hóa",
      });
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Tên đăng nhập hoặc mật khẩu không đúng",
      });
    }

    const userId = user._id?.toString?.() ?? user._id;
    const token = jwt.sign(
      { userId, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN },
    );

    const managedBranchIds =
      user.role === "BRANCH_MANAGER"
        ? (user.managedBranchIds || []).map((x) =>
            x?.toString?.() ?? String(x),
          )
        : null;

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: userId,
          username: user.username,
          fullName: user.fullName,
          role: user.role,
          branchId: user.branchId?.toString?.() ?? user.branchId ?? null,
          managedBranchIds,
        },
      },
      message: "Đăng nhập thành công",
    });
  } catch (err) {
    next(err);
  }
};
