'use client';

import { useEffect, useRef, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import {
  ArrowLeft,
  Play,
  Pause,
  SkipBack,
  SkipForward,
  Volume2,
  VolumeX,
  Maximize2,
  Settings,
  Heart,
  ListMusic,
  Repeat,
  Shuffle,
  Mic2,
  Type,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { Badge } from '@/components/ui/badge';
import { LyricsHighlight } from '@/components/player/LyricsHighlight';
import { mockSongs } from '@/mocks/songs';
import { mockLyrics } from '@/mocks/lyrics';
import { cn, formatDuration } from '@/lib/utils';

export default function PlayerPage({ params }: { params: { id: string } }) {
  const song = mockSongs.find((s) => s.youtubeId === params.id) ?? mockSongs[0];
  const queue = mockSongs.slice(1, 6);

  const [playing, setPlaying] = useState(true);
  const [currentTime, setCurrentTime] = useState(0);
  const [volume, setVolume] = useState(80);
  const [muted, setMuted] = useState(false);
  const [tvMode, setTvMode] = useState(false);
  const [fontSize, setFontSize] = useState<'sm' | 'md' | 'lg' | 'xl'>('lg');
  const [showQueue, setShowQueue] = useState(true);
  const [loop, setLoop] = useState(false);
  const [shuffle, setShuffle] = useState(false);

  // Simulate playback
  useEffect(() => {
    if (!playing) return;
    const interval = setInterval(() => {
      setCurrentTime((t) => {
        if (t >= song.duration) {
          setPlaying(false);
          return 0;
        }
        return t + 0.1;
      });
    }, 100);
    return () => clearInterval(interval);
  }, [playing, song.duration]);

  return (
    <div className={cn('h-screen flex flex-col bg-background overflow-hidden', tvMode && 'tv-mode')}>
      {/* Header */}
      {!tvMode && (
        <header className="flex items-center justify-between px-4 md:px-6 h-14 border-b border-border shrink-0">
          <div className="flex items-center gap-3 min-w-0">
            <Link href="/home">
              <Button size="icon-sm" variant="ghost">
                <ArrowLeft className="h-4 w-4" />
              </Button>
            </Link>
            <div className="min-w-0">
              <h2 className="text-sm font-semibold truncate">{song.title}</h2>
              <p className="text-xs text-muted-foreground truncate">{song.artist}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Badge variant="success" className="hidden md:inline-flex">
              <Mic2 className="h-3 w-3 mr-1" />
              Karaoke mode
            </Badge>
            <Button size="icon-sm" variant="ghost" onClick={() => setShowQueue(!showQueue)}>
              <ListMusic className="h-4 w-4" />
            </Button>
            <Button size="icon-sm" variant="ghost">
              <Settings className="h-4 w-4" />
            </Button>
            <Button size="icon-sm" variant="ghost" onClick={() => setTvMode(!tvMode)}>
              <Maximize2 className="h-4 w-4" />
            </Button>
          </div>
        </header>
      )}

      {/* Main content */}
      <div className="flex-1 flex min-h-0">
        {/* Left: Video + Lyrics */}
        <div className="flex-1 flex flex-col min-w-0">
          {/* Video area */}
          <div className={cn('relative w-full bg-black shrink-0', tvMode ? 'h-1/2' : 'aspect-video max-h-[50vh]')}>
            {/* YouTube iframe placeholder */}
            <div className="absolute inset-0 flex items-center justify-center">
              <Image
                src={song.thumbnailUrl}
                alt={song.title}
                fill
                className="object-cover opacity-80"
              />
              <div className="absolute inset-0 bg-black/40" />
              <div className="relative z-10 text-center text-white space-y-2">
                <Mic2 className="h-16 w-16 mx-auto opacity-50" />
                <p className="text-sm opacity-70">YouTube IFrame Player sẽ ở đây</p>
                <p className="text-xs opacity-50">videoId: {song.youtubeId}</p>
              </div>
            </div>
          </div>

          {/* Lyrics */}
          <div className="flex-1 relative bg-gradient-to-b from-background to-card min-h-0">
            <LyricsHighlight
              lyrics={mockLyrics}
              currentTime={currentTime}
              onSeek={setCurrentTime}
              fontSize={fontSize}
            />
            {/* Font size toggle */}
            <div className="absolute top-4 right-4 flex items-center gap-1 bg-card/80 backdrop-blur rounded-lg p-1">
              {(['sm', 'md', 'lg', 'xl'] as const).map((s) => (
                <Button
                  key={s}
                  size="icon-sm"
                  variant={fontSize === s ? 'secondary' : 'ghost'}
                  onClick={() => setFontSize(s)}
                  className="text-xs uppercase"
                >
                  {s}
                </Button>
              ))}
            </div>
          </div>
        </div>

        {/* Right: Queue sidebar */}
        {showQueue && !tvMode && (
          <aside className="hidden lg:flex flex-col w-80 border-l border-border bg-card shrink-0">
            <div className="p-4 border-b border-border flex items-center justify-between">
              <h3 className="font-semibold flex items-center gap-2">
                <ListMusic className="h-4 w-4" />
                Hàng chờ
              </h3>
              <Badge>{queue.length}</Badge>
            </div>
            <div className="flex-1 overflow-y-auto p-2 space-y-1">
              {queue.map((q, idx) => (
                <Link
                  key={q.youtubeId}
                  href={`/play/${q.youtubeId}`}
                  className="flex items-center gap-3 p-2 rounded-xl hover:bg-accent transition-all group"
                >
                  <span className="text-xs text-muted-foreground w-5 text-center">{idx + 1}</span>
                  <div className="relative w-12 h-12 rounded-lg overflow-hidden shrink-0">
                    <Image src={q.thumbnailUrl} alt={q.title} fill className="object-cover" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{q.title}</p>
                    <p className="text-xs text-muted-foreground truncate">{q.artist}</p>
                  </div>
                </Link>
              ))}
            </div>
            <div className="p-4 border-t border-border">
              <Button variant="outline" className="w-full" size="sm">
                Xóa hàng chờ
              </Button>
            </div>
          </aside>
        )}
      </div>

      {/* Player controls */}
      <div className="border-t border-border bg-card/80 backdrop-blur shrink-0">
        <div className="px-4 md:px-6 py-3 space-y-2">
          {/* Progress */}
          <div className="flex items-center gap-3">
            <span className="text-xs text-muted-foreground tabular-nums w-12 text-right">
              {formatDuration(currentTime)}
            </span>
            <Slider
              value={[currentTime]}
              onValueChange={(v) => setCurrentTime(v[0])}
              max={song.duration}
              step={0.1}
              className="flex-1"
            />
            <span className="text-xs text-muted-foreground tabular-nums w-12">
              {formatDuration(song.duration)}
            </span>
          </div>

          {/* Controls */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Button size="icon-sm" variant="ghost">
                <Heart className="h-4 w-4" />
              </Button>
              <Button
                size="icon-sm"
                variant={shuffle ? 'secondary' : 'ghost'}
                onClick={() => setShuffle(!shuffle)}
              >
                <Shuffle className="h-4 w-4" />
              </Button>
            </div>

            <div className="flex items-center gap-3">
              <Button size="icon-sm" variant="ghost">
                <SkipBack className="h-5 w-5" />
              </Button>
              <Button
                size="icon"
                variant="gradient"
                className="h-12 w-12 rounded-full"
                onClick={() => setPlaying(!playing)}
              >
                {playing ? <Pause className="h-5 w-5" /> : <Play className="h-5 w-5 ml-0.5" />}
              </Button>
              <Button size="icon-sm" variant="ghost">
                <SkipForward className="h-5 w-5" />
              </Button>
            </div>

            <div className="flex items-center gap-2">
              <Button
                size="icon-sm"
                variant={loop ? 'secondary' : 'ghost'}
                onClick={() => setLoop(!loop)}
              >
                <Repeat className="h-4 w-4" />
              </Button>
              <div className="hidden md:flex items-center gap-2">
                <Button size="icon-sm" variant="ghost" onClick={() => setMuted(!muted)}>
                  {muted ? <VolumeX className="h-4 w-4" /> : <Volume2 className="h-4 w-4" />}
                </Button>
                <Slider
                  value={[muted ? 0 : volume]}
                  onValueChange={(v) => {
                    setVolume(v[0]);
                    setMuted(false);
                  }}
                  max={100}
                  className="w-24"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
