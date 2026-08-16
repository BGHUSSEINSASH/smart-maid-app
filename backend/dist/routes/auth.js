"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const store_1 = require("../store");
const router = (0, express_1.Router)();
const loginSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
});
router.post('/login', (req, res) => {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
        return;
    }
    const user = store_1.users.find((candidate) => candidate.email.toLowerCase() === parsed.data.email.toLowerCase() &&
        candidate.password === parsed.data.password);
    if (!user) {
        res.status(401).json({ message: 'Invalid credentials' });
        return;
    }
    res.json({
        token: (0, store_1.makeToken)(user),
        user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
        },
    });
});
exports.default = router;
