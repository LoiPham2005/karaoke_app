import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { BillingService } from './billing.service';
import { CheckoutDto } from './dto/billing.dto';

@ApiTags('billing')
@Controller()
export class BillingController {
  constructor(private readonly billing: BillingService) {}

  @Public()
  @Get('subscriptions/plans')
  @ApiOperation({ summary: 'Bảng giá gói Premium' })
  plans() {
    return this.billing.getPlans();
  }

  @Get('subscriptions/me')
  @ApiOperation({ summary: 'Trạng thái Premium của tôi' })
  me(@CurrentUser('sub') userId: string) {
    return this.billing.getMySubscription(userId);
  }

  @Post('subscriptions/checkout')
  @ApiOperation({ summary: 'Tạo phiên thanh toán mua Premium' })
  checkout(@CurrentUser('sub') userId: string, @Body() dto: CheckoutDto) {
    return this.billing.checkout(userId, dto);
  }

  @Post('payments/:id/confirm-mock')
  @ApiOperation({ summary: '[DEV] Giả lập cổng thanh toán thành công' })
  confirmMock(@CurrentUser('sub') userId: string, @Param('id') id: string) {
    return this.billing.confirmMock(userId, id);
  }
}
