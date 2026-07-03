const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const admin = await prisma.user.findUnique({
    where: { email: 'admin@rkcnl.gov.np' }
  });
  console.log('Admin User:', JSON.stringify(admin, null, 2));
  await prisma.$disconnect();
}

main().catch(console.error);