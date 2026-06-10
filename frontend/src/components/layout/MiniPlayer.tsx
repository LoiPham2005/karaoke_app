'use client';

import Image from 'next/image';
import Link from 'next/link';
import { Play, Pause, SkipForward, SkipBack, Heart, Volume2, Maximize2, ListMusic } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { useState } from 'react';
import { mockSongs } from '@/mocks/songs';
import { formatDuration } from '@/lib/utils';

export function MiniPlayer() {
  const [playing, setPlaying] = useState(false);
  const [progress, setProgress] = useState(45);
  const [volume, setVolume] = useState(70);
  const song = mockSongs[0];

  return (
    <div className="fixed bottom-0 left-0 right-0 z-40 lg:left-64 glass border-t border-border">
      <div className="flex items-center gap-4 px-4 lg:px-6 h-20">
        <Link href={`/play/${song.youtubeId}`} className="flex items-center gap-3 min-w-0 lg:w-72">
          <Image
            src={song.thumbnailUrl}
            alt={song.title}
            width={56}
            height={56}
            className="rounded-lg w-14 h-14 object-cover"
          />
          <div className="min-w-0 hidden sm:block">
            <h4 className="text-sm font-semibold truncate">{song.title}</h4>
            <p className="text-xs text-muted-foreground truncate">{song.artist}</p>
          </div>
          <Button size="icon-sm" variant="ghost" className="hidden sm:flex">
            <Heart className="h-4 w-4" />
          </Button>
        </Link>

        <div className="flex-1 flex flex-col items-center gap-1">
          <div className="flex items-center gap-2">
            <Button size="icon-sm" variant="ghost" className="hidden md:flex">
              <SkipBack className="h-4 w-4" />
            </Button>
            <Button
              size="icon"
              variant="gradient"
              className="h-10 w-10 rounded-full"
              onClick={() => setPlaying(!playing)}
            >
              {playing ? <Pause className="h-5 w-5" /> : <Play className="h-5 w-5 ml-0.5" />}
            </Button>
            <Button size="icon-sm" variant="ghost" className="hidden md:flex">
              <SkipForward className="h-4 w-4" />
            </Button>
          </div>
          <div className="hidden md:flex items-center gap-2 w-full max-w-md">
            <span className="text-xs text-muted-foreground tabular-nums">
              {formatDuration((progress / 100) * song.duration)}
            </span>
            <Slider
              value={[progress]}
              onValueChange={(v) => setProgress(v[0])}
              max={100}
              step={0.1}
              className="flex-1"
            />
            <span className="text-xs text-muted-foreground tabular-nums">
              {formatDuration(song.duration)}
            </span>
          </div>
        </div>

        <div className="hidden lg:flex items-center gap-2 w-48">
          <Button size="icon-sm" variant="ghost">
            <ListMusic className="h-4 w-4" />
          </Button>
          <Volume2 className="h-4 w-4 text-muted-foreground" />
          <Slider value={[volume]} onValueChange={(v) => setVolume(v[0])} max={100} className="w-20" />
          <Link href={`/play/${song.youtubeId}`}>
            <Button size="icon-sm" variant="ghost">
              <Maximize2 className="h-4 w-4" />
            </Button>
          </Link>
        </div>
      </div>
    </div>
  );
}
