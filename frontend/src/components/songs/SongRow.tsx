'use client';

import Image from 'next/image';
import Link from 'next/link';
import { Play, Heart, MoreVertical, Plus } from 'lucide-react';
import { Song } from '@/types';
import { formatDuration, formatNumber } from '@/lib/utils';
import { Button } from '@/components/ui/button';

interface SongRowProps {
  song: Song;
  index?: number;
}

export function SongRow({ song, index }: SongRowProps) {
  return (
    <div className="group flex items-center gap-4 px-4 py-2 rounded-xl hover:bg-accent transition-all">
      {index !== undefined && (
        <span className="w-6 text-center text-sm text-muted-foreground tabular-nums">
          {index}
        </span>
      )}
      <Link href={`/play/${song.youtubeId}`} className="relative w-12 h-12 shrink-0">
        <Image
          src={song.thumbnailUrl}
          alt={song.title}
          fill
          className="object-cover rounded-lg"
        />
        <div className="absolute inset-0 bg-black/50 rounded-lg opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
          <Play className="h-4 w-4 text-white" />
        </div>
      </Link>
      <Link href={`/song/${song.youtubeId}`} className="flex-1 min-w-0">
        <h4 className="text-sm font-medium truncate">{song.title}</h4>
        <p className="text-xs text-muted-foreground truncate">{song.artist}</p>
      </Link>
      <span className="hidden md:block text-xs text-muted-foreground">
        {formatNumber(song.viewCount)}
      </span>
      <span className="text-xs text-muted-foreground tabular-nums w-12 text-right">
        {formatDuration(song.duration)}
      </span>
      <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
        <Button size="icon-sm" variant="ghost">
          <Plus className="h-4 w-4" />
        </Button>
        <Button size="icon-sm" variant="ghost">
          <Heart className="h-4 w-4" />
        </Button>
        <Button size="icon-sm" variant="ghost">
          <MoreVertical className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}
