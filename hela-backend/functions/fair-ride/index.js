/**
 * InsForge Edge Function: Fair Ride Fare Calculator
 */
module.exports = async function(request) {
  try {
    const body = await request.json();
    const { vehicleType = 'Tuk-Tuk', distanceKm = 1 } = body;

    const rates = {
      'Tuk-Tuk': { base: 120, perKm: 90 },
      'Car': { base: 250, perKm: 140 },
      'Van': { base: 350, perKm: 180 },
      'Scooter': { base: 80, perKm: 60 },
    };

    const config = rates[vehicleType] || rates['Tuk-Tuk'];
    const estimatedFare = Math.round(config.base + (distanceKm * config.perKm));

    return new Response(JSON.stringify({
      success: true,
      vehicleType,
      distanceKm,
      estimatedFareLkr: estimatedFare,
      fairPriceRange: {
        min: Math.round(estimatedFare * 0.95),
        max: Math.round(estimatedFare * 1.15),
      },
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
};
