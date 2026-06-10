'use client';

import Image from 'next/image';
import { GripVertical, X, Play, Plus, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { mockSongs } from '@/mocks/songs';
import { formatDuration } from '@/lib/utils';

export default function QueuePage() {
  const nowPlaying = mockSongs[0];
  const upNext = mockSongs.slice(1, 6);
  const recommended = mockSongs.slice(6, 12);

  return (
    <div className="container py-6 space-y-8 max-w-4xl">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Hàng chờ phát</h1>
          <p className="text-muted-foreground mt-1">Quản lý bài hát đang chờ phát tiếp theo</p>
        </div>
        <Button variant="outline">
          <Trash2 className="h-4 w-4 mr-2" />
          Xóa toàn bộ
        </Button>
      </div>

      {/* Now playing */}
      <section>
        <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-3">
          Đang phát
        </h2>
        <div className="bg-card rounded-2xl p-4 flex items-center gap-4 border border-primary/30">
          <div className="relative w-16 h-16 rounded-xl overflow-hidden shrink-0">
            <Image src={nowPlaying.thumbnailUrl} alt={nowPlaying.title} fill className="object-cover" />
            <div className="absolute inset-0 bg-primary/20 flex items-center justify-center">
              <Play className="h-6 w-6 text-white" fill="white" />
            </div>
          </div>
          <div className="flex-1 min-w-0">
            <h3 className="font-semibold truncate">{nowPlaying.title}</h3>
            <p className="text-sm text-muted-foreground truncate">{nowPlaying.artist}</p>
          </div>
          <Badge variant="default" className="animate-pulse">
            Đang phát
          </Badge>
        </div>
      </section>

      {/* Up next - manually added */}
      <section>
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider">
            Tiếp theo ({upNext.length})
          </h2>
          <span className="text-xs text-muted-foreground">Kéo thả để sắp xếp</span>
        </div>
        <div className="space-y-2">
          {upNext.map((song, idx) => (
            <div
              key={song.youtubeId}
              className="group flex items-center gap-3 bg-card rounded-xl p-3 hover:bg-accent transition-all cursor-grab"
            >
              <GripVertical className="h-4 w-4 text-muted-foreground opacity-0 group-hover:opacity-100" />
              <span className="text-sm text-muted-foreground w-6 text-center tabular-nums">{idx + 1}</span>
              <div className="relative w-12 h-12 rounded-lg overflow-hidden shrink-0">
                <Image src={song.thumbnailUrl} alt={song.title} fill className="object-cover" />
              </div>
              <div className="flex-1 min-w-0">
                <h4 className="text-sm font-medium truncate">{song.title}</h4>
                <p className="text-xs text-muted-foreground truncate">{song.artist}</p>
              </div>
              <span className="text-xs text-muted-foreground tabular-nums">
                {formatDuration(song.duration)}
              </span>
              <Button
                size="icon-sm"
                variant="ghost"
                className="opacity-0 group-hover:opacity-100"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>
          ))}
        </div>
      </section>

      {/* Auto recommended */}
      <section>
        <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-3">
          Đề xuất tự động
        </h2>
        <div className="space-y-2">
          {recommended.map((song) => (
            <div
              key={song.youtubeId}
              className="group flex items-center gap-3 bg-card/50 rounded-xl p-3 hover:bg-accent transition-all"
            >
              <div className="relative w-12 h-12 rounded-lg overflow-hidden shrink-0">
                <Image src={song.thumbnailUrl} alt={song.title} fill className="object-cover" />
              </div>
              <div className="flex-1 min-w-0">
                <h4 className="text-sm font-medium truncate">{song.title}</h4>
                <p className="text-xs text-muted-foreground truncate">{song.artist}</p>
              </div>
              <span className="text-xs text-muted-foreground tabular-nums">
                {formatDuration(song.duration)}
              </span>
              <Button size="icon-sm" variant="ghost">
                <Plus className="h-4 w-4" />
              </Button>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
