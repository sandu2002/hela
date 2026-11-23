const fs = require('fs');
const path = require('path');
const db = require('../config/db');

async function runMigrations() {
  console.log('🔄 Running migrations for HELA database on InsForge...');
  try {
    const schemaSql = fs.readFileSync(path.join(__dirname, '../database/schema.sql'), 'utf-8');
    console.log('📄 Applying schema.sql...');
    await db.query(schemaSql);
    console.log('✅ Schema applied successfully.');

    const seedSql = fs.readFileSync(path.join(__dirname, '../database/seed.sql'), 'utf-8');
    console.log('🌱 Applying seed.sql...');
    await db.query(seedSql);
    console.log('✅ Seed data applied successfully.');

    console.log('🎉 Migration completed successfully!');
  } catch (err) {
    console.error('❌ Migration failed:', err.message);
    process.exit(1);
  }
}

runMigrations();
