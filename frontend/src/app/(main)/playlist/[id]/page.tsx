import Image from 'next/image';
import { Play, Shuffle, Plus, Share2, Edit, MoreVertical, ListMusic, Clock, Globe, Lock } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { SongRow } from '@/components/songs/SongRow';
import { mockPlaylists } from '@/mocks/playlists';
import { formatDuration } from '@/lib/utils';

export default function PlaylistDetailPage({ params }: { params: { id: string } }) {
  const playlist = mockPlaylists.find((p) => p.id === params.id) ?? mockPlaylists[0];

  return (
    <div className="relative">
      {/* Hero backdrop */}
      <div className="relative h-[300px] -mt-16">
        <div className="absolute inset-0">
          {playlist.coverUrl && (
            <Image src={playlist.coverUrl} alt={playlist.name} fill className="object-cover blur-2xl opacity-40" />
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
              <span className="font-medium text-foreground">{playlist.ownerName}</span>
              <span>·</span>
              <span>{playlist.songCount} bài</span>
              <span>·</span>
              <span className="flex items-center gap-1">
                <Clock className="h-3 w-3" />
                {formatDuration(playlist.totalDuration)}
              </span>
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="flex flex-wrap items-center gap-3">
          <Button size="lg" variant="gradient">
            <Play className="mr-2 h-5 w-5" />
            Phát tất cả
          </Button>
          <Button size="lg" variant="outline">
            <Shuffle className="mr-2 h-4 w-4" />
            Shuffle
          </Button>
          <Button size="icon" variant="ghost">
            <Plus className="h-5 w-5" />
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
          {playlist.songs?.map((song, idx) => (
            <SongRow key={song.youtubeId} song={song} index={idx + 1} />
          ))}
        </div>
      </div>
    </div>
  );
}
