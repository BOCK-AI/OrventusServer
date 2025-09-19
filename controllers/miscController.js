// controllers/miscController.js
import axios from 'axios';
import { StatusCodes } from 'http-status-codes';

export const getGooglePlaces = async (req, res) => {
  const { input } = req.query; // Get the search term from the query params

  if (!input) {
    return res.status(StatusCodes.BAD_REQUEST).json({ msg: 'Input query is required' });
  }

  const apiKey = process.env.GOOGLE_API_KEY; // We'll store the key securely in .env
  const url = `https://maps.googleapis.com/maps/api/place/autocomplete/json`;

  try {
    const response = await axios.get(url, {
      params: {
        input: input,
        key: apiKey,
        components: 'country:in',
      },
    });
    
    // Send Google's response back to our Flutter app
    res.status(StatusCodes.OK).json(response.data);

  } catch (error) {
    console.error('Google Places API Error:', error.response?.data);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ msg: 'Failed to fetch places' });
  }
};