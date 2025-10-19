import { PrismaClient } from '@prisma/client';
import { StatusCodes } from 'http-status-codes';

const prisma = new PrismaClient();

export const getAllDocumentTypes = async (req, res) => {
  const documentTypes = await prisma.documentType.findMany({ orderBy: { name: 'asc' } });
  res.status(StatusCodes.OK).json({ documentTypes });
};

export const createDocumentType = async (req, res) => {
  const { name, requiresExpiry } = req.body;
  const newDocType = await prisma.documentType.create({ data: { name, requiresExpiry } });
  res.status(StatusCodes.CREATED).json({ documentType: newDocType });
};

export const updateDocumentType = async (req, res) => {
  const { id } = req.params;
  const { name, requiresExpiry, isActive } = req.body;
  const updatedDocType = await prisma.documentType.update({
    where: { id: parseInt(id) },
    data: { name, requiresExpiry, isActive },
  });
  res.status(StatusCodes.OK).json({ documentType: updatedDocType });
};

export const deleteDocumentType = async (req, res) => {
  const { id } = req.params;
  await prisma.documentType.delete({ where: { id: parseInt(id) } });
  res.status(StatusCodes.OK).json({ msg: 'Document type deleted successfully' });
};