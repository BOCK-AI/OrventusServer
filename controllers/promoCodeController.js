// controllers/promoCodeController.js
import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';

const prisma = new PrismaClient();

export const getAllPromoCodes = async (req, res) => {
  const promoCodes = await prisma.promoCode.findMany({ orderBy: { createdAt: 'desc' } });
  res.status(StatusCodes.OK).json({ promoCodes });
};

export const createPromoCode = async (req, res) => {
  try {
    const { code, usageLimit, expiryDate, discountValue, discountType } = req.body;
    if (!code || !discountValue || !expiryDate) {
      throw new BadRequestError('Code, discount value, and expiry date are required');
    }
    const newPromoCode = await prisma.promoCode.create({
      data: {
        code,
        usageLimit: parseInt(usageLimit) || 0,
        expiryDate,
        discountValue: parseFloat(discountValue),
        discountType: discountType || 'percentage',
      },
    });
    res.status(StatusCodes.CREATED).json({ promoCode: newPromoCode });
  } catch (error) {
    console.error("--- CRASH in createPromoCode ---", error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ msg: error.message || 'Failed to create promo code' });
  }
};

export const updatePromoCode = async (req, res) => {
  const { id } = req.params;
  const { code, usageLimit, expiryDate, discountValue, discountType, isActive } = req.body;
  const updatedPromoCode = await prisma.promoCode.update({
    where: { id: parseInt(id) },
    data: { code, usageLimit: parseInt(usageLimit), expiryDate, discountValue: parseFloat(discountValue), discountType, isActive },
  });
  res.status(StatusCodes.OK).json({ promoCode: updatedPromoCode });
};

export const deletePromoCode = async (req, res) => {
  const { id } = req.params;
  await prisma.promoCode.delete({ where: { id: parseInt(id) } });
  res.status(StatusCodes.OK).json({ msg: 'Promo code deleted successfully' });
};