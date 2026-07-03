/**
 * prisma/seed.js
 *
 * Seeds the database with an initial Admin user.
 * Run with:  node prisma/seed.js
 *
 * WARNING: Only run once on a fresh database or it will error
 * if the email already exists.
 */

require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
    const email = process.env.ADMIN_EMAIL;
    const password = process.env.ADMIN_PASSWORD;
    const username = process.env.ADMIN_USERNAME || 'RKCNL Admin';

    if (!email || !password) {
        console.error('❌ Missing ADMIN_EMAIL or ADMIN_PASSWORD in .env file.');
        process.exit(1);
    }

    console.log('🌱 Seeding database...\n');

    // ── Admin User ──────────────────────────────────────────────────
    const existingAdmin = await prisma.user.findUnique({ where: { email } });

    if (existingAdmin) {
        console.log(`ℹ️  Admin already exists: ${email}`);
        await prisma.user.update({
            where: { email },
            data: { status: 'Approved', isActive: true }
        });
        console.log('✅ Admin user status updated to Approved.');
    } else {
        const passwordHash = await bcrypt.hash(password, 10);

        const admin = await prisma.user.create({
            data: {
                username,
                email,
                passwordHash,
                role: 'Admin',
                gender: 'Other',
                dateOfBirth: '1990-01-01',
                phone: '9800000000',
                location: 'Kathmandu',
                isActive: true,
                status: 'Approved'
            }
        });

        console.log('✅ Admin user created:');
        console.log(`   ID:       ${admin.id}`);
        console.log(`   Email:    ${admin.email}`);
        console.log(`   Username: ${admin.username}`);
        console.log(`   Role:     ${admin.role}`);
        console.log(`   Password: ${password}  ← change this after first login!\n`);
    }

    // ── Sample Categories ───────────────────────────────────────────
    const categories = [
        { name: 'Agriculture', description: 'Agricultural surveys and field data collection' },
        { name: 'Health', description: 'Health and sanitation related surveys' },
        { name: 'Education', description: 'Educational institutions and literacy surveys' },
        { name: 'Infrastructure', description: 'Road, water, and infrastructure surveys' },
        { name: 'General', description: 'General purpose surveys' }
    ];

    for (const cat of categories) {
        const existing = await prisma.category.findUnique({ where: { name: cat.name } });
        if (!existing) {
            await prisma.category.create({ data: cat });
            console.log(`✅ Category created: ${cat.name}`);
        } else {
            console.log(`ℹ️  Category already exists: ${cat.name}`);
        }
    }

    console.log('\n🎉 Seeding complete.');
}

main()
    .catch(e => {
        console.error('❌ Seeding failed:', e.message);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
