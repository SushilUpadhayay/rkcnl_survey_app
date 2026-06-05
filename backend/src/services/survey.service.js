/**
 * src/services/survey.service.js
 * 
 * Survey service.
 * Responsibilities:
 * - Implement business logic for surveys
 * - Fetch survey data from the database
 */

const getAllSurveys = async () => {
  // TODO: Implement database fetching
  // Currently returning mock data based on the requested architecture
  return [
    {
      id: 'SRV-001',
      title: 'Crop Health Assessment – Ward 4',
      region: 'Northern Sector',
      status: 'pending'
    },
    {
      id: 'SRV-002',
      title: 'Soil Moisture Survey – East Plains',
      region: 'Eastern Plains',
      status: 'in_progress'
    }
  ];
};

module.exports = {
  getAllSurveys
};
