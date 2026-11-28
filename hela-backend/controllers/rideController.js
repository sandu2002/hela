const db = require('../config/db');
const { userOwnsIdentifier } = require('../middleware/authMiddleware');

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
    const { vehicleType = 'Tuk-Tuk', distanceKm, quotedFareLkr, pickupAddress, dropoffAddress, userId } = req.body || {};

    if (typeof vehicleType !== 'string' || !Object.prototype.hasOwnProperty.call(BASE_RATES_LKR, vehicleType)) {
      return res.status(400).json({ error: 'Invalid vehicleType. Allowed: Tuk-Tuk, Car, Van, Scooter' });
    }

    const parsedDistance = Number(distanceKm);
    if (!Number.isFinite(parsedDistance) || parsedDistance <= 0 || parsedDistance > 2000) {
      return res.status(400).json({ error: 'distanceKm must be a finite number between 0 and 2000' });
    }

    let parsedQuoted = null;
    if (quotedFareLkr !== undefined && quotedFareLkr !== null && quotedFareLkr !== '') {
      parsedQuoted = Number(quotedFareLkr);
      if (!Number.isFinite(parsedQuoted) || parsedQuoted < 0 || parsedQuoted > 1_000_000) {
        return res.status(400).json({ error: 'quotedFareLkr must be a non-negative finite number' });
      }
    }

    const rateConfig = BASE_RATES_LKR[vehicleType];
    const estimatedFare = Math.round(rateConfig.base + parsedDistance * rateConfig.perKm);

    // Check if quoted fare is fair (within 15% tolerance)
    let isFair = true;
    let difference = 0;
    if (parsedQuoted !== null) {
      difference = Math.round(parsedQuoted - estimatedFare);
      isFair = parsedQuoted <= estimatedFare * 1.15;
    }

    // Save record only for authenticated owners
    if (userId) {
      if (!req.authUser) {
        return res.status(401).json({ error: 'Authentication required to record ride history' });
      }
      const authorized = await userOwnsIdentifier(req.authUser, userId);
      if (!authorized) {
        return res.status(403).json({ error: 'Forbidden: cannot record ride for another user' });
      }
      const cleanPickup = typeof pickupAddress === 'string' ? pickupAddress.trim().slice(0, 240) : 'N/A';
      const cleanDropoff = typeof dropoffAddress === 'string' ? dropoffAddress.trim().slice(0, 240) : 'N/A';
      await db.query(`
        INSERT INTO public.fair_rides (
          user_id, vehicle_type, pickup_address, dropoff_address, distance_km,
          estimated_fare_lkr, quoted_fare_lkr, is_fair, status
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'estimated')
      `, [userId, vehicleType, cleanPickup || 'N/A', cleanDropoff || 'N/A', parsedDistance, estimatedFare, parsedQuoted, isFair]);
    }

    res.json({
      success: true,
      vehicleType,
      distanceKm: parsedDistance,
      estimatedFareLkr: estimatedFare,
      quotedFareLkr: parsedQuoted,
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
    const targetId = typeof userId === 'string' ? userId.trim() : '';
    if (!targetId || targetId.length > 128) {
      return res.status(400).json({ error: 'Invalid user identifier' });
    }

    const authorized = await userOwnsIdentifier(req.authUser, targetId);
    if (!authorized) {
      return res.status(403).json({ error: 'Forbidden: cannot read another user ride history' });
    }

    const rides = await db.query('SELECT * FROM public.fair_rides WHERE user_id::text = $1 ORDER BY created_at DESC LIMIT 100', [targetId]);
    res.json({ success: true, count: rides.length, rides });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
