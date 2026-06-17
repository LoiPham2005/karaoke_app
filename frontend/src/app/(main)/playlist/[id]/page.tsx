'use client';

import { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useParams, useRouter } from 'next/navigation';
import { useQueryClient } from '@tanstack/react-query';
import { Play, Shuffle, Share2, Edit, MoreVertical, ListMusic, Clock, Globe, Lock, Loader2 } from 'lucide-react';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { SongRow } from '@/components/songs/SongRow';
import { usePlaylist, qk } from '@/lib/queries';
import { addToQueue, clearQueue, toSongRef } from '@/lib/library';
import { useAuthStore } from '@/stores/auth.store';
import { formatDuration } from '@/lib/utils';
import type { Song } from '@/types';

export default function PlaylistDetailPage() {
  const params = useParams();
  const router = useRouter();
  const qc = useQueryClient();
  const id = String(params.id ?? '');
  const user = useAuthStore((s) => s.user);
  const [enqueuing, setEnqueuing] = useState(false);

  const { data: playlist, isLoading, isError } = usePlaylist(id);

  // Chưa đăng nhập → mời đăng nhập (playlist là dữ liệu cá nhân, cần Bearer).
  if (!user) {
    return (
      <div className="container py-10 text-center">
        <ListMusic className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
        <h3 className="font-semibold mb-1">Đăng nhập để xem playlist</h3>
        <Link href="/login">
          <Button variant="gradient" className="mt-3">
            Đăng nhập
          </Button>
        </Link>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="container py-10 space-y-4">
        <div className="h-56 w-56 rounded-3xl bg-card animate-pulse" />
        <div className="h-8 w-64 rounded bg-card animate-pulse" />
        <div className="space-y-2">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="h-14 rounded-xl bg-card animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  if (isError || !playlist) {
    return (
      <div className="container py-10 text-center">
        <ListMusic className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
        <h3 className="font-semibold mb-1">Không tìm thấy playlist</h3>
        <p className="text-sm text-muted-foreground mb-3">
          Playlist không tồn tại hoặc bạn không có quyền xem.
        </p>
        <Link href="/library?tab=playlists">
          <Button variant="outline">Về thư viện</Button>
        </Link>
      </div>
    );
  }

  const songs = playlist.items?.map((it) => it.song) ?? [];
  const totalDuration = songs.reduce((sum, s) => sum + (s.duration ?? 0), 0);

  // Nạp danh sách vào hàng chờ (server /queue) rồi mở player bài đầu. Hàng chờ
  // ở màn hát đọc từ /queue nên phải enqueue thật thì sidebar mới hiện.
  const playList = async (list: Song[]) => {
    if (list.length === 0 || enqueuing) return;
    setEnqueuing(true);
    try {
      await clearQueue();
      // Thêm tuần tự để giữ đúng thứ tự (position do backend tăng dần).
      for (const s of list) {
        await addToQueue(toSongRef(s));
      }
      await qc.invalidateQueries({ queryKey: qk.queue });
      router.push(`/play/${list[0].youtubeId}`);
    } catch {
      toast.error('Không thể phát playlist');
      setEnqueuing(false);
    }
  };

  const handlePlayAll = () => playList(songs);
  const handleShuffle = () =>
    playList([...songs].sort(() => Math.random() - 0.5));

  return (
    <div className="relative">
      {/* Hero backdrop */}
      <div className="relative h-[300px] -mt-16">
        <div className="absolute inset-0">
          {playlist.coverUrl && (
            <Image
              src={playlist.coverUrl}
              alt={playlist.name}
              fill
              className="object-cover blur-2xl opacity-40"
            />
          )}
          <div className="absolute inset-0 bg-gradient-to-b from-transparent to-background" />
        </div>
      </div>

      <div className="container -mt-40 relative space-y-6">
        <div className="flex flex-col md:flex-row gap-6 items-end">
          <div className="relative w-56 h-56 rounded-3xl overflow-hidden shadow-2xl shrink-0">
            {playlist.coverUrl ? (
              <Image src={playlist.coverUrl} alt={playlist.name} fill className="object-cover" />
            ) : (
              <div className="w-full h-full gradient-primary flex items-center justify-center">
                <ListMusic className="h-24 w-24 text-white/50" />
              </div>
            )}
          </div>
          <div className="flex-1 space-y-3 pb-4">
            <div className="flex items-center gap-2">
              {playlist.isPublic ? (
                <Badge variant="success">
                  <Globe className="h-3 w-3 mr-1" />
                  Công khai
                </Badge>
              ) : (
                <Badge variant="outline">
                  <Lock className="h-3 w-3 mr-1" />
                  Riêng tư
                </Badge>
              )}
            </div>
            <h1 className="text-4xl md:text-6xl font-bold">{playlist.name}</h1>
            {playlist.description && (
              <p className="text-muted-foreground">{playlist.description}</p>
            )}
            <div className="flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
              <span>{songs.length} bài</span>
              <span>·</span>
              <span className="flex items-center gap-1">
                <Clock className="h-3 w-3" />
                {formatDuration(totalDuration)}
              </span>
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="flex flex-wrap items-center gap-3">
          <Button
            size="lg"
            variant="gradient"
            onClick={handlePlayAll}
            disabled={songs.length === 0 || enqueuing}
          >
            {enqueuing ? (
              <Loader2 className="mr-2 h-5 w-5 animate-spin" />
            ) : (
              <Play className="mr-2 h-5 w-5" />
            )}
            Phát tất cả
          </Button>
          <Button
            size="lg"
            variant="outline"
            onClick={handleShuffle}
            disabled={songs.length === 0 || enqueuing}
          >
            <Shuffle className="mr-2 h-4 w-4" />
            Shuffle
          </Button>
          <Button size="icon" variant="ghost">
            <Share2 className="h-5 w-5" />
          </Button>
          <Button size="icon" variant="ghost">
            <Edit className="h-5 w-5" />
          </Button>
          <Button size="icon" variant="ghost">
            <MoreVertical className="h-5 w-5" />
          </Button>
        </div>

        {/* Songs */}
        {songs.length === 0 ? (
          <div className="bg-card rounded-2xl p-10 text-center">
            <ListMusic className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
            <p className="text-sm text-muted-foreground">
              Playlist trống. Thêm bài từ màn hát hoặc chi tiết bài.
            </p>
          </div>
        ) : (
          <div className="bg-card rounded-2xl p-3 space-y-1">
            <div className="flex items-center gap-4 px-4 py-2 text-xs text-muted-foreground uppercase tracking-wider border-b border-border mb-2">
              <span className="w-6 text-center">#</span>
              <span className="w-12">&nbsp;</span>
              <span className="flex-1">Tiêu đề</span>
              <span className="hidden md:block">Lượt xem</span>
              <span className="w-12 text-right">
                <Clock className="h-4 w-4 ml-auto" />
              </span>
            </div>
            {songs.map((song, idx) => (
              <SongRow key={`${song.youtubeId}-${idx}`} song={song} index={idx + 1} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
