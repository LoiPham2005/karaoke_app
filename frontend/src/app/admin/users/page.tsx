'use client';

import { useState } from 'react';
import { Search, Filter, MoreVertical, Crown, Shield, Ban } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';

const mockAdminUsers = Array.from({ length: 15 }, (_, i) => ({
  id: `user-${i + 1}`,
  name: `Nguyễn Văn ${String.fromCharCode(65 + i)}`,
  email: `user${i + 1}@gmail.com`,
  avatar: `https://i.pravatar.cc/200?img=${i + 1}`,
  role: i === 0 ? 'ADMIN' : i < 3 ? 'MODERATOR' : 'USER',
  premium: i % 4 === 0,
  status: i % 7 === 0 ? 'BANNED' : 'ACTIVE',
  lastActive: `${i + 1} giờ trước`,
  createdAt: `2025-${String((i % 12) + 1).padStart(2, '0')}-15`,
}));

export default function AdminUsersPage() {
  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState('all');

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Quản lý người dùng</h1>
          <p className="text-muted-foreground mt-1">12,847 người dùng tổng</p>
        </div>
        <Button variant="gradient">Export CSV</Button>
      </div>

      {/* Filters */}
      <div className="flex flex-col md:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Tìm theo tên, email..."
            className="pl-10"
          />
        </div>
        <div className="flex items-center gap-2">
          {['all', 'admin', 'mod', 'user', 'premium', 'banned'].map((f) => (
            <Badge
              key={f}
              variant={filter === f ? 'default' : 'outline'}
              className="cursor-pointer px-3 py-1.5 capitalize"
              onClick={() => setFilter(f)}
            >
              {f}
            </Badge>
          ))}
        </div>
      </div>

      {/* Table */}
      <div className="bg-card rounded-2xl overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="text-left text-xs text-muted-foreground uppercase tracking-wider border-b border-border">
              <th className="px-6 py-4">Người dùng</th>
              <th className="px-6 py-4 hidden md:table-cell">Role</th>
              <th className="px-6 py-4 hidden md:table-cell">Status</th>
              <th className="px-6 py-4 hidden lg:table-cell">Hoạt động</th>
              <th className="px-6 py-4 hidden lg:table-cell">Tham gia</th>
              <th className="px-6 py-4"></th>
            </tr>
          </thead>
          <tbody>
            {mockAdminUsers.map((u) => (
              <tr key={u.id} className="border-b border-border last:border-0 hover:bg-accent/50 transition-colors">
                <td className="px-6 py-3">
                  <div className="flex items-center gap-3">
                    <Avatar className="h-9 w-9">
                      <AvatarImage src={u.avatar} />
                      <AvatarFallback>{u.name[0]}</AvatarFallback>
                    </Avatar>
                    <div className="min-w-0">
                      <p className="text-sm font-medium flex items-center gap-1">
                        {u.name}
                        {u.premium && <Crown className="h-3 w-3 text-amber-400" />}
                      </p>
                      <p className="text-xs text-muted-foreground">{u.email}</p>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-3 hidden md:table-cell">
                  <Badge
                    variant={u.role === 'ADMIN' ? 'default' : u.role === 'MODERATOR' ? 'secondary' : 'outline'}
                  >
                    {u.role === 'ADMIN' && <Shield className="h-3 w-3 mr-1" />}
                    {u.role}
                  </Badge>
                </td>
                <td className="px-6 py-3 hidden md:table-cell">
                  {u.status === 'BANNED' ? (
                    <Badge variant="destructive">
                      <Ban className="h-3 w-3 mr-1" />
                      Banned
                    </Badge>
                  ) : (
                    <Badge variant="success">Active</Badge>
                  )}
                </td>
                <td className="px-6 py-3 hidden lg:table-cell text-sm text-muted-foreground">
                  {u.lastActive}
                </td>
                <td className="px-6 py-3 hidden lg:table-cell text-sm text-muted-foreground">
                  {u.createdAt}
                </td>
                <td className="px-6 py-3 text-right">
                  <Button size="icon-sm" variant="ghost">
                    <MoreVertical className="h-4 w-4" />
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
