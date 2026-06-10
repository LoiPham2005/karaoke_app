'use client';

import { useState } from 'react';
import { Check, X, Eye, Play } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { mockSongs } from '@/mocks/songs';

const mockReports = mockSongs.slice(0, 15).map((song, i) => ({
  id: `r-${i + 1}`,
  song,
  reason: [
    'Video không phát được',
    'Sai lyrics',
    'Audio bị lệch',
    'Nội dung không phù hợp',
    'Bản quyền',
  ][i % 5],
  detail: 'User báo cáo chi tiết về vấn đề này...',
  user: { name: `user_${i + 1}`, email: `user${i + 1}@gmail.com` },
  status: i % 3 === 0 ? 'RESOLVED' : i % 3 === 1 ? 'PENDING' : 'REJECTED',
  createdAt: `${i + 1} giờ trước`,
}));

export default function AdminReportsPage() {
  const [filter, setFilter] = useState('PENDING');
  const filtered = mockReports.filter((r) => filter === 'ALL' || r.status === filter);

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Báo cáo bài hát</h1>
        <p className="text-muted-foreground mt-1">{mockReports.length} báo cáo từ người dùng</p>
      </div>

      <div className="flex items-center gap-2">
        {[
          { id: 'ALL', label: 'Tất cả' },
          { id: 'PENDING', label: 'Chờ xử lý' },
          { id: 'RESOLVED', label: 'Đã xử lý' },
          { id: 'REJECTED', label: 'Từ chối' },
        ].map((f) => (
          <Badge
            key={f.id}
            variant={filter === f.id ? 'default' : 'outline'}
            className="cursor-pointer px-4 py-1.5"
            onClick={() => setFilter(f.id)}
          >
            {f.label}
          </Badge>
        ))}
      </div>

      <div className="space-y-3">
        {filtered.map((r) => (
          <div key={r.id} className="bg-card rounded-2xl p-4 flex items-start gap-4">
            <img
              src={r.song.thumbnailUrl}
              alt={r.song.title}
              className="w-20 h-20 rounded-xl object-cover shrink-0"
            />
            <div className="flex-1 min-w-0 space-y-2">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <h3 className="font-semibold">{r.song.title}</h3>
                  <p className="text-sm text-muted-foreground">{r.song.artist}</p>
                </div>
                {r.status === 'PENDING' && <Badge variant="warning">Chờ xử lý</Badge>}
                {r.status === 'RESOLVED' && <Badge variant="success">Đã xử lý</Badge>}
                {r.status === 'REJECTED' && <Badge variant="destructive">Từ chối</Badge>}
              </div>
              <div>
                <p className="text-sm font-medium">Lý do: {r.reason}</p>
                <p className="text-xs text-muted-foreground mt-1">{r.detail}</p>
              </div>
              <div className="flex items-center justify-between flex-wrap gap-2">
                <p className="text-xs text-muted-foreground">
                  Báo bởi <span className="font-medium text-foreground">@{r.user.name}</span> ·{' '}
                  {r.createdAt}
                </p>
                {r.status === 'PENDING' && (
                  <div className="flex items-center gap-2">
                    <Button size="sm" variant="outline">
                      <Play className="h-3 w-3 mr-1" />
                      Phát thử
                    </Button>
                    <Button size="sm" variant="destructive">
                      <X className="h-3 w-3 mr-1" />
                      Từ chối
                    </Button>
                    <Button size="sm" variant="gradient">
                      <Check className="h-3 w-3 mr-1" />
                      Xử lý
                    </Button>
                  </div>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
