import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PaymentProvider, UserPlan } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { CheckoutDto } from './dto/billing.dto';

interface PlanInfo {
  plan: UserPlan;
  label: string;
  priceVnd: number; // Int VND
  durationDays: number;
}

// Bảng giá gói Premium B2C (VND). Có thể chuyển sang SystemSetting sau.
const PLANS: Record<string, PlanInfo> = {
  PREMIUM_MONTHLY: {
    plan: 'PREMIUM_MONTHLY',
    label: 'Premium tháng',
    priceVnd: 49000,
    durationDays: 30,
  },
  PREMIUM_YEARLY: {
    plan: 'PREMIUM_YEARLY',
    label: 'Premium năm',
    priceVnd: 490000,
    durationDays: 365,
  },
};

@Injectable()
export class BillingService {
  constructor(private readonly prisma: PrismaService) {}

  /// Danh sách gói (public — hiển thị bảng giá).
  getPlans() {
    return Object.values(PLANS).map((p) => ({
      plan: p.plan,
      label: p.label,
      priceVnd: p.priceVnd,
      durationDays: p.durationDays,
    }));
  }

  /// Trạng thái premium hiện tại của user.
  async getMySubscription(userId: string) {
    const now = new Date();
    const sub = await this.prisma.subscription.findFirst({
      where: { userId, status: 'ACTIVE', currentPeriodEnd: { gt: now } },
      orderBy: { currentPeriodEnd: 'desc' },
    });
    return {
      isPremium: !!sub,
      plan: sub?.userPlan ?? null,
      status: sub?.status ?? null,
      currentPeriodEnd: sub?.currentPeriodEnd ?? null,
      autoRenew: sub?.autoRenew ?? false,
    };
  }

  /// Tạo phiên thanh toán: 1 Subscription (chờ kích hoạt) + 1 Payment PENDING.
  /// Trả payUrl. THỰC TẾ: payUrl = URL cổng VNPay/Momo (ký từ payment.id+amount).
  /// DEV: payUrl trỏ endpoint mock-confirm để test luồng end-to-end.
  async checkout(userId: string, dto: CheckoutDto) {
    const info = PLANS[dto.plan];
    if (!info) throw new BadRequestException('Gói không hợp lệ');
    const now = new Date();

    const sub = await this.prisma.subscription.create({
      data: {
        subscriberType: 'USER',
        userId,
        userPlan: info.plan,
        status: 'TRIALING', // placeholder tới khi thanh toán thành công
        currentPeriodStart: now,
        currentPeriodEnd: now,
      },
    });

    const payment = await this.prisma.payment.create({
      data: {
        amount: info.priceVnd,
        currency: 'VND',
        provider: dto.provider ?? PaymentProvider.VNPAY,
        status: 'PENDING',
        userId,
        subscriptionId: sub.id,
        description: `Mua ${info.label}`,
      },
    });

    return {
      paymentId: payment.id,
      subscriptionId: sub.id,
      amount: info.priceVnd,
      plan: info.plan,
      provider: payment.provider,
      // ⚠️ DEV mock. Thực tế thay bằng URL cổng thanh toán (VNPay/Momo).
      payUrl: `/api/v1/payments/${payment.id}/confirm-mock`,
    };
  }

  /// DEV ONLY: giả lập cổng báo thành công → Payment PAID + Subscription ACTIVE
  /// + set User.isPremium + premiumUntil. Thực tế: VNPay/Momo IPN/callback thay
  /// chỗ này (verify chữ ký rồi gọi cùng logic kích hoạt).
  async confirmMock(userId: string, paymentId: string) {
    if (process.env.NODE_ENV === 'production') {
      throw new ForbiddenException('confirm-mock bị tắt ở môi trường production');
    }
    const payment = await this.prisma.payment.findUnique({ where: { id: paymentId } });
    if (!payment || payment.userId !== userId) {
      throw new NotFoundException('Không tìm thấy giao dịch');
    }
    if (!payment.subscriptionId) {
      throw new BadRequestException('Giao dịch không gắn gói');
    }
    const sub = await this.prisma.subscription.findUnique({
      where: { id: payment.subscriptionId },
    });
    if (!sub || !sub.userPlan) throw new NotFoundException('Không tìm thấy gói');

    const info = PLANS[sub.userPlan];
    const now = new Date();
    const periodEnd = new Date(now.getTime() + info.durationDays * 24 * 3600 * 1000);

    await this.prisma.$transaction([
      this.prisma.payment.update({
        where: { id: payment.id },
        data: { status: 'PAID', paidAt: now },
      }),
      this.prisma.subscription.update({
        where: { id: sub.id },
        data: { status: 'ACTIVE', currentPeriodStart: now, currentPeriodEnd: periodEnd },
      }),
      this.prisma.user.update({
        where: { id: userId },
        data: { isPremium: true, premiumUntil: periodEnd },
      }),
    ]);

    return { success: true, plan: sub.userPlan, premiumUntil: periodEnd };
  }
}
