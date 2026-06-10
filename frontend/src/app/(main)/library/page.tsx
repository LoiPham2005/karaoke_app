'use client';

import Link from 'next/link';
import Image from 'next/image';
import { Plus, ListMusic, Heart, History, Music2, MoreVertical, Lock, Globe } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Badge } from '@/components/ui/badge';
import { SongRow } from '@/components/songs/SongRow';
import { mockPlaylists } from '@/mocks/playlists';
import { mockSongs } from '@/mocks/songs';
import { formatDuration, timeAgo } from '@/lib/utils';

const historyGroups = [
  { label: 'Hôm nay', songs: mockSongs.slice(0, 3) },
  { label: 'Hôm qua', songs: mockSongs.slice(3, 6) },
  { label: 'Tuần này', songs: mockSongs.slice(6, 10) },
  { label: 'Cũ hơn', songs: mockSongs.slice(10, 15) },
];

export default function LibraryPage() {
  return (
    <div className="container py-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold">Thư viện của tôi</h1>
          <p className="text-muted-foreground mt-1">Playlist, yêu thích và lịch sử hát</p>
        </div>
        <Button variant="gradient">
          <Plus className="h-4 w-4 mr-2" />
          Tạo playlist
        </Button>
      </div>

      <Tabs defaultValue="playlists">
        <TabsList>
          <TabsTrigger value="playlists">
            <ListMusic className="h-4 w-4 mr-2" />
            Playlist
          </TabsTrigger>
          <TabsTrigger value="favorites">
            <Heart className="h-4 w-4 mr-2" />
            Yêu thích
          </TabsTrigger>
          <TabsTrigger value="history">
            <History className="h-4 w-4 mr-2" />
            Lịch sử
          </TabsTrigger>
          <TabsTrigger value="contributions">
            <Music2 className="h-4 w-4 mr-2" />
            Đóng góp
          </TabsTrigger>
        </TabsList>

        {/* PLAYLISTS */}
        <TabsContent value="playlists" className="mt-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {/* Create new */}
            <button className="aspect-square rounded-2xl border-2 border-dashed border-border hover:border-primary hover:bg-card transition-all flex flex-col items-center justify-center gap-3 text-muted-foreground hover:text-primary">
              <Plus className="h-12 w-12" />
              <span className="font-medium">Tạo playlist mới</span>
            </button>
            {mockPlaylists.map((pl) => (
              <Link
                key={pl.id}
                href={`/playlist/${pl.id}`}
                className="group rounded-2xl bg-card hover:bg-accent transition-all p-3"
              >
                <div className="relative aspect-square rounded-xl overflow-hidden mb-3">
                  {pl.coverUrl ? (
                    <Image src={pl.coverUrl} alt={pl.name} fill className="object-cover" />
                  ) : (
                    <div className="w-full h-full gradient-primary flex items-center justify-center">
                      <ListMusic className="h-16 w-16 text-white/50" />
                    </div>
                  )}
                  <div className="absolute top-2 right-2">
                    {pl.isPublic ? (
                      <Badge variant="success" className="text-xs">
                        <Globe className="h-3 w-3 mr-1" />
                        Public
                      </Badge>
                    ) : (
                      <Badge variant="outline" className="text-xs bg-background/80">
                        <Lock className="h-3 w-3 mr-1" />
                        Private
                      </Badge>
                    )}
                  </div>
                </div>
                <div className="flex items-start justify-between">
                  <div className="min-w-0">
                    <h3 className="font-semibold truncate">{pl.name}</h3>
                    <p className="text-xs text-muted-foreground">
                      {pl.songCount} bài · {formatDuration(pl.totalDuration)}
                    </p>
                  </div>
                  <Button
                    size="icon-sm"
                    variant="ghost"
                    onClick={(e) => e.preventDefault()}
                    className="opacity-0 group-hover:opacity-100 transition-opacity"
                  >
                    <MoreVertical className="h-4 w-4" />
                  </Button>
                </div>
              </Link>
            ))}
          </div>
        </TabsContent>

        {/* FAVORITES */}
        <TabsContent value="favorites" className="mt-6">
          <div className="bg-card rounded-2xl p-3 space-y-1">
            {mockSongs.slice(0, 12).map((song, idx) => (
              <SongRow key={song.youtubeId} song={song} index={idx + 1} />
            ))}
          </div>
        </TabsContent>

        {/* HISTORY */}
        <TabsContent value="history" className="mt-6 space-y-6">
          {historyGroups.map((group) => (
            <div key={group.label}>
              <h3 className="text-sm font-semibold text-muted-foreground mb-3 px-2">
                {group.label}
              </h3>
              <div className="bg-card rounded-2xl p-3 space-y-1">
                {group.songs.map((song) => (
                  <SongRow key={song.youtubeId} song={song} />
                ))}
              </div>
            </div>
          ))}
        </TabsContent>

        {/* CONTRIBUTIONS */}
        <TabsContent value="contributions" className="mt-6">
          <div className="bg-card rounded-2xl p-6 text-center">
            <Music2 className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
            <h3 className="font-semibold mb-1">Đóng góp lyrics</h3>
            <p className="text-sm text-muted-foreground mb-4">
              Giúp cộng đồng bằng cách đóng góp lời bài hát chuẩn xác
            </p>
            <Button variant="outline">Xem hướng dẫn</Button>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}
