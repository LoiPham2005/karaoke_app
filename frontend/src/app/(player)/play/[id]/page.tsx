'use client';

import { useEffect, useRef, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import YouTube, { type YouTubeEvent, type YouTubePlayer } from 'react-youtube';
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
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { Badge } from '@/components/ui/badge';
import { LyricsHighlight } from '@/components/player/LyricsHighlight';
import { mockSongs } from '@/mocks/songs';
import { mockLyrics } from '@/mocks/lyrics';
import { cn, formatDuration } from '@/lib/utils';

export default function PlayerPage() {
  const params = useParams();
  const videoId = String(params.id ?? '');

  // Nếu bài nằm trong mock thì lấy metadata; nếu là id từ YouTube search thì
  // metadata thật sẽ được lấy từ player.onReady (getVideoData).
  const mock = mockSongs.find((s) => s.youtubeId === videoId);
  const queue = mockSongs.filter((s) => s.youtubeId !== videoId).slice(0, 5);

  const playerRef = useRef<YouTubePlayer | null>(null);
  const [title, setTitle] = useState(mock?.title ?? 'Đang tải...');
  const [author, setAuthor] = useState(mock?.artist ?? '');
  const [duration, setDuration] = useState(mock?.duration ?? 0);
  const [playing, setPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [volume, setVolume] = useState(80);
  const [muted, setMuted] = useState(false);
  const [tvMode, setTvMode] = useState(false);
  const [fontSize, setFontSize] = useState<'sm' | 'md' | 'lg' | 'xl'>('lg');
  const [showQueue, setShowQueue] = useState(true);
  const [loop, setLoop] = useState(false);
  const [shuffle, setShuffle] = useState(false);

  // Poll thời gian phát thật từ player → sync progress + lyrics highlight.
  useEffect(() => {
    if (!playing) return;
    const interval = setInterval(() => {
      const t = playerRef.current?.getCurrentTime?.();
      if (typeof t === 'number') setCurrentTime(t);
    }, 250);
    return () => clearInterval(interval);
  }, [playing]);

  const onReady = (e: YouTubeEvent) => {
    playerRef.current = e.target;
    try {
      const d = e.target.getDuration();
      if (d) setDuration(d);
      const data = e.target.getVideoData();
      if (data?.title) setTitle(data.title);
      if (data?.author) setAuthor(data.author);
      e.target.setVolume(volume);
    } catch {
      // ignore — player chưa sẵn sàng
    }
  };

  const onStateChange = (e: YouTubeEvent) => {
    // YT.PlayerState: 1 = playing, 2 = paused, 0 = ended
    if (e.data === 1) setPlaying(true);
    else if (e.data === 2) setPlaying(false);
    else if (e.data === 0) {
      if (loop) {
        e.target.seekTo(0, true);
        e.target.playVideo();
      } else {
        setPlaying(false);
      }
    }
  };

  const togglePlay = () => {
    const p = playerRef.current;
    if (!p) return;
    if (playing) p.pauseVideo();
    else p.playVideo();
  };

  const seek = (t: number) => {
    setCurrentTime(t);
    playerRef.current?.seekTo(t, true);
  };

  const changeVolume = (v: number) => {
    setVolume(v);
    setMuted(false);
    playerRef.current?.unMute();
    playerRef.current?.setVolume(v);
  };

  const toggleMute = () => {
    const p = playerRef.current;
    if (!p) return;
    if (muted) {
      p.unMute();
      setMuted(false);
    } else {
      p.mute();
      setMuted(true);
    }
  };

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
              <h2 className="text-sm font-semibold truncate">{title}</h2>
              <p className="text-xs text-muted-foreground truncate">{author}</p>
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
          {/* Video area — YouTube IFrame player thật */}
          <div
            className={cn(
              'relative w-full bg-black shrink-0',
              tvMode ? 'h-1/2' : 'aspect-video max-h-[50vh]',
            )}
          >
            {videoId ? (
              <YouTube
                videoId={videoId}
                onReady={onReady}
                onStateChange={onStateChange}
                className="absolute inset-0 h-full w-full"
                iframeClassName="h-full w-full"
                opts={{
                  width: '100%',
                  height: '100%',
                  playerVars: {
                    autoplay: 1,
                    modestbranding: 1,
                    rel: 0,
                    playsinline: 1,
                  },
                }}
              />
            ) : (
              <div className="absolute inset-0 flex items-center justify-center text-white/60">
                Không có videoId
              </div>
            )}
          </div>

          {/* Lyrics */}
          <div className="flex-1 relative bg-gradient-to-b from-background to-card min-h-0">
            <LyricsHighlight
              lyrics={mockLyrics}
              currentTime={currentTime}
              onSeek={seek}
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
              {formatDuration(Math.floor(currentTime))}
            </span>
            <Slider
              value={[currentTime]}
              onValueChange={(v) => seek(v[0])}
              max={duration || 1}
              step={1}
              className="flex-1"
            />
            <span className="text-xs text-muted-foreground tabular-nums w-12">
              {formatDuration(duration)}
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
                onClick={togglePlay}
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
                <Button size="icon-sm" variant="ghost" onClick={toggleMute}>
                  {muted ? <VolumeX className="h-4 w-4" /> : <Volume2 className="h-4 w-4" />}
                </Button>
                <Slider
                  value={[muted ? 0 : volume]}
                  onValueChange={(v) => changeVolume(v[0])}
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
