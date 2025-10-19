import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';

const prisma = new PrismaClient();

export const getDashboardStats = async (req, res) => {
  try {
    // We are temporarily removing auth for debugging. We will add it back.
    console.log("--- [SUCCESS] Entered getDashboardStats controller ---");

    const revenueAggregation = await prisma.ride.aggregate({_sum: {fare: true}, where: {status: 'COMPLETED'}});
    const totalRevenue = revenueAggregation._sum.fare || 0;

    const completedRides = await prisma.ride.count({ where: { status: 'COMPLETED' } });
    const cancelledRides = await prisma.ride.count({ where: { status: 'CANCELLED' } });
    const totalRides = await prisma.ride.count();

    const vehicleCounts = await prisma.ride.groupBy({ by: ['vehicle'], _count: { vehicle: true } });
    const totalOrderByServices = vehicleCounts.reduce((acc, item) => {
      acc[item.vehicle] = item._count.vehicle;
      return acc;
    }, {});

    const stats = {
      todaySummary: { totalRevenue, completedRides, cancelledRides, totalRides },
      totalOrderByServices,
    };
    return res.status(StatusCodes.OK).json(stats);
  } catch (error) {
    console.error("Error fetching dashboard stats:", error);
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ msg: 'Failed to fetch dashboard stats' });
  }
};

// Add this new function to controllers/statsController.js
export const getEarningsReport = async (req, res) => {
  try {
    // 1. Get all completed rides and include the related user names
    const completedRides = await prisma.ride.findMany({
      where: { status: 'COMPLETED' },
      include: {
        customer: { select: { name: true } },
        rider: { select: { name: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    // 2. Calculate the summary numbers
    const totalFare = completedRides.reduce((sum, ride) => sum + ride.fare, 0);
    const siteCommission = completedRides.reduce((sum, ride) => sum + ride.commission, 0);
    const driverEarnings = totalFare - siteCommission;
    // We don't have discounts yet, so we'll hardcode it to 0 for now
    const totalDiscount = 0;

    // 3. Send back the full report
    res.status(StatusCodes.OK).json({
      summary: {
        totalFare,
        siteCommission,
        driverEarnings,
        totalDiscount,
      },
      transactions: completedRides, // The list of rides is our transactions
    });

  } catch (error) {
    console.error("Error fetching earnings report:", error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ msg: 'Failed to fetch earnings report' });
  }
};