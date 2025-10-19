import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';

const prisma = new PrismaClient();

export const getAllNotifications = async (req, res) => {
  const notifications = await prisma.notification.findMany({ orderBy: { createdAt: 'desc' } });
  res.status(StatusCodes.OK).json({ notifications });
};

export const createNotification = async (req, res) => {
  const { type, title, message } = req.body;
  const newNotification = await prisma.notification.create({
    data: { type, title, message },
  });
  // In a real app, this is where you would trigger the push notification service (e.g., FCM)
  res.status(StatusCodes.CREATED).json({ notification: newNotification });
};