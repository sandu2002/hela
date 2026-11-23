const db = require('../config/db');

/**
 * Ride Controller - Fair Ride Price Estimations & Anti-Overcharging Algorithm
 */

// Official/Fair Rates per KM in Sri Lanka (LKR)
const BASE_RATES_LKR = {
  'Tuk-Tuk': { base: 120, perKm: 90 },
  'Car': { base: 250, perKm: 140 },
  'Van': { base: 350, perKm: 180 },
  'Scooter': { base: 80, perKm: 60 },
};

exports.calculateFairFare = async (req, res) => {
  try {
    const { vehicleType = 'Tuk-Tuk', distanceKm, quotedFareLkr, pickupAddress, dropoffAddress, userId } = req.body;
    
    const rateConfig = BASE_RATES_LKR[vehicleType] || BASE_RATES_LKR['Tuk-Tuk'];
    const estimatedFare = Math.round(rateConfig.base + (distanceKm * rateConfig.perKm));
    
    // Check if quoted fare is fair (within 15% tolerance)
    let isFair = true;
    let difference = 0;
    if (quotedFareLkr) {
      difference = quotedFareLkr - estimatedFare;
      isFair = quotedFareLkr <= (estimatedFare * 1.15);
    }

    // Save record if userId is provided
    if (userId) {
      await db.query(`
        INSERT INTO public.fair_rides (
          user_id, vehicle_type, pickup_address, dropoff_address, distance_km,
          estimated_fare_lkr, quoted_fare_lkr, is_fair, status
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'estimated')
      `, [userId, vehicleType, pickupAddress || 'N/A', dropoffAddress || 'N/A', distanceKm, estimatedFare, quotedFareLkr || null, isFair]);
    }

    res.json({
      success: true,
      vehicleType,
      distanceKm,
      estimatedFareLkr: estimatedFare,
      quotedFareLkr: quotedFareLkr || null,
      isFair,
      differenceLkr: difference,
      fairPriceRange: {
        min: Math.round(estimatedFare * 0.95),
        max: Math.round(estimatedFare * 1.15),
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getRideHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const rides = await db.query('SELECT * FROM public.fair_rides WHERE user_id::text = $1 ORDER BY created_at DESC', [userId]);
    res.json({ success: true, count: rides.length, rides });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
