import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import User from '../models/users.js';

const JWT_SECRET = process.env.JWT_SECRET || 'rcms-jwt-secret-change-in-production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

export const login = async (req, res, next) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username và password là bắt buộc',
      });
    }

    // .lean() trả về plain object, tránh lỗi Cast khi _id trong DB là string (vd: "user_admin")
    const user = await User.findOne({ username: username.trim() }).lean();
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Tên đăng nhập hoặc mật khẩu không đúng',
      });
    }

    if (user.status !== 'ACTIVE') {
      return res.status(403).json({
        success: false,
        message: 'Tài khoản đã bị vô hiệu hóa',
      });
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Tên đăng nhập hoặc mật khẩu không đúng',
      });
    }

    const userId = user._id?.toString?.() ?? user._id;
    const token = jwt.sign(
      { userId, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

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
        },
      },
      message: 'Đăng nhập thành công',
    });
  } catch (err) {
    next(err);
  }
};
