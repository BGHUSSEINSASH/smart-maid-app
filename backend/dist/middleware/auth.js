"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = requireAuth;
const store_1 = require("../store");
function requireAuth(req, res, next) {
    const authorization = req.header('authorization') ?? '';
    const token = authorization.startsWith('Bearer ') ? authorization.slice(7) : undefined;
    const user = (0, store_1.parseUserFromToken)(token);
    if (!user) {
        res.status(401).json({ message: 'Unauthorized' });
        return;
    }
    req.user = user;
    next();
}
