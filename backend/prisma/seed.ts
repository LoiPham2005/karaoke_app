import { PrismaClient, Role } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  const adminPassword = await argon2.hash('Admin@12345');
  const admin = await prisma.user.upsert({
    where: { email: 'admin@karaoke.local' },
    update: {},
    create: {
      email: 'admin@karaoke.local',
      passwordHash: adminPassword,
      displayName: 'Admin',
      role: Role.ADMIN,
      isEmailVerified: true,
    },
  });
  console.log('✅ Admin created:', admin.email);

  const userPassword = await argon2.hash('User@12345');
  const demoUser = await prisma.user.upsert({
    where: { email: 'demo@karaoke.local' },
    update: {},
    create: {
      email: 'demo@karaoke.local',
      passwordHash: userPassword,
      displayName: 'Demo User',
      role: Role.USER,
      isEmailVerified: true,
    },
  });
  console.log('✅ Demo user created:', demoUser.email);

  console.log('🌱 Seeding done!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
