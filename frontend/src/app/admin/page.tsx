import { Users, Music2, Play, DollarSign, TrendingUp, AlertCircle, FileText } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import Link from 'next/link';

const stats = [
  { label: 'Tổng người dùng', value: '12,847', change: '+12%', icon: Users, color: 'text-blue-400' },
  { label: 'DAU', value: '3,421', change: '+5%', icon: TrendingUp, color: 'text-emerald-400' },
  { label: 'Bài hát phát', value: '847K', change: '+23%', icon: Play, color: 'text-pink-400' },
  { label: 'Doanh thu tháng', value: '12.5M', change: '+8%', icon: DollarSign, color: 'text-amber-400' },
];

const pendingReports = [
  { id: 1, song: 'Hoa Nở Không Màu', reason: 'Video không phát được', user: 'user_001', time: '2 giờ trước' },
  { id: 2, song: 'Despacito', reason: 'Sai lyrics', user: 'user_002', time: '4 giờ trước' },
  { id: 3, song: 'Em Của Ngày Hôm Qua', reason: 'Audio bị lệch', user: 'user_003', time: '6 giờ trước' },
];

const pendingLyrics = [
  { id: 1, song: 'Chúng Ta Của Hiện Tại', user: 'sky_fan', time: '1 giờ trước' },
  { id: 2, song: 'Sầu Tím Thiệp Hồng', user: 'bolero_lover', time: '3 giờ trước' },
];

export default function AdminDashboardPage() {
  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground mt-1">Tổng quan hệ thống</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((s) => (
          <div key={s.label} className="bg-card rounded-2xl p-5 space-y-2">
            <div className="flex items-center justify-between">
              <s.icon className={`h-5 w-5 ${s.color}`} />
              <Badge variant="success" className="text-xs">
                {s.change}
              </Badge>
            </div>
            <p className="text-2xl font-bold">{s.value}</p>
            <p className="text-xs text-muted-foreground">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Charts placeholder */}
      <div className="grid lg:grid-cols-2 gap-4">
        <div className="bg-card rounded-2xl p-6">
          <h3 className="font-semibold mb-4">Tăng trưởng người dùng</h3>
          <div className="h-64 flex items-end gap-2">
            {Array.from({ length: 14 }, (_, i) => (
              <div
                key={i}
                className="flex-1 gradient-primary rounded-t-lg"
                style={{ height: `${30 + Math.random() * 70}%` }}
              />
            ))}
          </div>
        </div>

        <div className="bg-card rounded-2xl p-6">
          <h3 className="font-semibold mb-4">Top 5 bài hát hôm nay</h3>
          <div className="space-y-3">
            {[
              { title: 'Hoa Nở Không Màu', plays: 12450 },
              { title: 'Despacito', plays: 9820 },
              { title: 'Em Của Ngày Hôm Qua', plays: 7340 },
              { title: 'Shape of You', plays: 6210 },
              { title: 'Faded', plays: 5890 },
            ].map((s, idx) => (
              <div key={s.title} className="flex items-center gap-3">
                <span className="w-6 text-lg font-bold text-muted-foreground">{idx + 1}</span>
                <span className="flex-1 truncate text-sm">{s.title}</span>
                <span className="text-sm text-muted-foreground">{s.plays.toLocaleString()}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Pending actions */}
      <div className="grid lg:grid-cols-2 gap-4">
        <div className="bg-card rounded-2xl p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold flex items-center gap-2">
              <AlertCircle className="h-5 w-5 text-amber-400" />
              Báo cáo chờ xử lý
            </h3>
            <Link href="/admin/reports">
              <Button size="sm" variant="ghost">
                Xem tất cả →
              </Button>
            </Link>
          </div>
          <div className="space-y-2">
            {pendingReports.map((r) => (
              <div key={r.id} className="flex items-center gap-3 p-3 rounded-xl hover:bg-accent">
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{r.song}</p>
                  <p className="text-xs text-muted-foreground">{r.reason}</p>
                </div>
                <span className="text-xs text-muted-foreground">{r.time}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-card rounded-2xl p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold flex items-center gap-2">
              <FileText className="h-5 w-5 text-blue-400" />
              Lyrics chờ duyệt
            </h3>
            <Link href="/admin/lyrics">
              <Button size="sm" variant="ghost">
                Xem tất cả →
              </Button>
            </Link>
          </div>
          <div className="space-y-2">
            {pendingLyrics.map((l) => (
              <div key={l.id} className="flex items-center gap-3 p-3 rounded-xl hover:bg-accent">
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{l.song}</p>
                  <p className="text-xs text-muted-foreground">bởi @{l.user}</p>
                </div>
                <span className="text-xs text-muted-foreground">{l.time}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
