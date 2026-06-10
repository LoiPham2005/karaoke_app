import Link from 'next/link';
import { LayoutDashboard, Users, Flag, FileText, Music2, Settings, LogOut } from 'lucide-react';
import { Logo } from '@/components/common/Logo';

const nav = [
  { href: '/admin', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/admin/users', label: 'Người dùng', icon: Users },
  { href: '/admin/reports', label: 'Báo cáo', icon: Flag },
  { href: '/admin/lyrics', label: 'Lyrics đóng góp', icon: FileText },
  { href: '/admin/songs', label: 'Bài hát', icon: Music2 },
  { href: '/admin/settings', label: 'Cài đặt', icon: Settings },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-background">
      <aside className="w-64 border-r border-border bg-card/30 flex flex-col h-screen sticky top-0">
        <div className="p-6 border-b border-border">
          <Logo />
          <p className="text-xs text-muted-foreground mt-2">Admin Panel</p>
        </div>
        <nav className="flex-1 p-3 space-y-1">
          {nav.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-muted-foreground hover:bg-accent hover:text-foreground transition-all"
            >
              <item.icon className="h-4 w-4" />
              {item.label}
            </Link>
          ))}
        </nav>
        <div className="p-3 border-t border-border space-y-1">
          <Link
            href="/home"
            className="flex items-center gap-3 px-3 py-2 rounded-xl text-sm text-muted-foreground hover:bg-accent transition-all"
          >
            <LogOut className="h-4 w-4" />
            Về app người dùng
          </Link>
        </div>
      </aside>
      <main className="flex-1">{children}</main>
    </div>
  );
}
