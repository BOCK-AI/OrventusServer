// controllers/reviewController.js
import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';

const prisma = new PrismaClient();

export const getAllReviews = async (req, res) => {
  const reviews = await prisma.review.findMany({
    include: {
      // We need to go through the ride to get the customer and driver names
      ride: {
        include: {
          customer: { select: { name: true } },
          rider: { select: { name: true } },
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });
  res.status(StatusCodes.OK).json({ reviews });
};