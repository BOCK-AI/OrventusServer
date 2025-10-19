import axios from 'axios';
import { StatusCodes } from 'http-status-codes';
import { BadRequestError } from '../errors/index.js';

export const getGooglePlaces = async (req, res) => {
  const { input } = req.query;
  if (!input) return res.status(StatusCodes.OK).json({ predictions: [] }); // Return empty for empty input
  const apiKey = process.env.GOOGLE_API_KEY;
  const url = `https://maps.googleapis.com/maps/api/place/autocomplete/json`;
  try {
    const response = await axios.get(url, { params: { input, key: apiKey, components: 'country:in' } });
    res.status(StatusCodes.OK).json(response.data);
  } catch (error) {
    console.error('Google Places API Error:', error.response?.data);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ msg: 'Failed to fetch places' });
  }
};

export const getGooglePlaceDetails = async (req, res) => {
  const { placeId } = req.query;
  if (!placeId) throw new BadRequestError('Place ID is required.');
  const apiKey = process.env.GOOGLE_API_KEY;
  const url = `https://maps.googleapis.com/maps/api/place/details/json`;
  try {
    const response = await axios.get(url, { params: { place_id: placeId, key: apiKey, fields: 'formatted_address,geometry' } });
    res.status(StatusCodes.OK).json(response.data);
  } catch (error) {
    console.error('Google Place Details API Error:', error.response?.data);
    throw new BadRequestError('Could not fetch place details.');
  }
};