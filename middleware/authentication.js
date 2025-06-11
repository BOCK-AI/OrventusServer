import jwt from "jsonwebtoken";
import { PrismaClient } from "../generated/prisma/index.js";
import NotFoundError from "../errors/not-found.js";
import UnauthenticatedError from "../errors/unauthenticated.js";

const prisma = new PrismaClient();

const auth = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer")) {
    throw new UnauthenticatedError("Authentication invalid");
  }
  const token = authHeader.split(" ")[1];
  try {
    const payload = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
    req.user = { id: payload.id, phone: payload.phone };
    req.socket = req.io;

    const user = await prisma.user.findUnique({ where: { id: payload.id } });
    if (!user) {
      throw new NotFoundError("User not found");
    }

    next();
  } catch (error) {
    throw new UnauthenticatedError("Authentication invalid");
  }
};

export default auth;
