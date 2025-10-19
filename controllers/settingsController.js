// controllers/settingsController.js

// --- THIS IS THE FIX ---
// The import for PrismaClient was likely incorrect or missing
import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';

// We must create the instance of the client
const prisma = new PrismaClient();
// --- END FIX ---

export const getAllSettings = async (req, res) => {
  try {
    console.log("--- [SUCCESS] Entered getAllSettings controller ---");
    // This line will now work because 'prisma' is a valid object
    const settingsArray = await prisma.setting.findMany();
    
    const settings = settingsArray.reduce((acc, setting) => {
      acc[setting.key] = setting.value;
      return acc;
    }, {});
    
    res.status(StatusCodes.OK).json({ settings });
  } catch (error) {
    console.error("--- CRASH in getAllSettings ---", error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ msg: error.message });
  }
};

export const updateSettings = async (req, res) => {
  try {
    const settingsToUpdate = req.body;
    const updatePromises = Object.keys(settingsToUpdate).map(key => {
      return prisma.setting.upsert({
        where: { key },
        update: { value: settingsToUpdate[key] },
        create: { key, value: settingsToUpdate[key] },
      });
    });
    await Promise.all(updatePromises);
    res.status(StatusCodes.OK).json({ msg: 'Settings updated successfully' });
  } catch (error) {
    console.error("--- CRASH in updateSettings ---", error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ msg: error.message });
  }
};