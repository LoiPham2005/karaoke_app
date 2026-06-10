import Link from 'next/link';
import Image from 'next/image';
import { Play, TrendingUp, Sparkles, Music2 } from 'lucide-react';
import { SongCard } from '@/components/songs/SongCard';
import { SongRow } from '@/components/songs/SongRow';
import { Button } from '@/components/ui/button';
import { ScrollArea, ScrollBar } from '@/components/ui/scroll-area';
import { mockSongs, trendingSongs, recommendedSongs, newReleases } from '@/mocks/songs';
import { categories } from '@/mocks/categories';
import { cn, formatNumber } from '@/lib/utils';

export default function HomePage() {
  const heroSong = mockSongs[0];

  return (
    <div className="container py-6 space-y-10">
      {/* HERO BANNER */}
      <section className="relative rounded-3xl overflow-hidden">
        <div className="absolute inset-0">
          <Image src={heroSong.thumbnailUrl} alt={heroSong.title} fill className="object-cover" />
          <div className="absolute inset-0 bg-gradient-to-r from-background via-background/80 to-transparent" />
        </div>
        <div className="relative p-8 md:p-12 max-w-2xl space-y-4">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/20 text-primary text-xs font-semibold">
            <TrendingUp className="h-3 w-3" />
            Đang hot nhất
          </div>
          <h1 className="text-3xl md:text-5xl font-bold">{heroSong.title}</h1>
          <p className="text-lg text-muted-foreground">{heroSong.artist}</p>
          <p className="text-sm text-muted-foreground">
            {formatNumber(heroSong.viewCount)} lượt xem · Có lời đồng bộ
          </p>
          <div className="flex items-center gap-3 pt-2">
            <Link href={`/play/${heroSong.youtubeId}`}>
              <Button size="lg" variant="gradient">
                <Play className="mr-2 h-5 w-5" />
                Hát ngay
              </Button>
            </Link>
            <Button size="lg" variant="outline">
              Thêm vào playlist
            </Button>
          </div>
        </div>
      </section>

      {/* TRENDING */}
      <section id="trending">
        <SectionHeader title="🔥 Đang trending" desc="Top 10 bài hot nhất tuần này" href="/category/trending" />
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
          {trendingSongs.slice(0, 10).map((song) => (
            <SongCard key={song.youtubeId} song={song} />
          ))}
        </div>
      </section>

      {/* CATEGORIES */}
      <section>
        <SectionHeader title="🎵 Thể loại" desc="Hát theo phong cách bạn thích" />
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-3">
          {categories.map((cat) => (
            <Link
              key={cat.slug}
              href={`/category/${cat.slug}`}
              className={cn(
                'group relative overflow-hidden rounded-2xl p-4 aspect-square flex flex-col justify-between bg-gradient-to-br',
                cat.gradient,
                'hover:scale-105 transition-transform',
              )}
            >
              <span className="text-3xl">{cat.icon}</span>
              <div>
                <h3 className="text-lg font-bold text-white">{cat.name}</h3>
                <p className="text-xs text-white/70">{cat.songCount} bài</p>
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* RECOMMENDED */}
      <section>
        <SectionHeader title="✨ Đề xuất cho bạn" desc="Dựa trên lịch sử hát của bạn" />
        <ScrollArea className="w-full whitespace-nowrap">
          <div className="flex gap-4 pb-4">
            {recommendedSongs.map((song) => (
              <div key={song.youtubeId} className="w-48 shrink-0">
                <SongCard song={song} />
              </div>
            ))}
          </div>
          <ScrollBar orientation="horizontal" />
        </ScrollArea>
      </section>

      {/* TOP CHARTS */}
      <section>
        <SectionHeader title="🏆 Top 5 tuần này" desc="Bài được hát nhiều nhất" />
        <div className="grid md:grid-cols-2 gap-2 bg-card rounded-2xl p-3">
          {trendingSongs.slice(0, 10).map((song, idx) => (
            <SongRow key={song.youtubeId} song={song} index={idx + 1} />
          ))}
        </div>
      </section>

      {/* NEW RELEASES */}
      <section id="new">
        <SectionHeader title="🆕 Mới ra" desc="Karaoke mới upload" />
        <ScrollArea className="w-full whitespace-nowrap">
          <div className="flex gap-4 pb-4">
            {newReleases.map((song) => (
              <div key={song.youtubeId} className="w-48 shrink-0">
                <SongCard song={song} />
              </div>
            ))}
          </div>
          <ScrollBar orientation="horizontal" />
        </ScrollArea>
      </section>
    </div>
  );
}

function SectionHeader({ title, desc, href }: { title: string; desc?: string; href?: string }) {
  return (
    <div className="flex items-end justify-between mb-4">
      <div>
        <h2 className="text-2xl font-bold">{title}</h2>
        {desc && <p className="text-sm text-muted-foreground mt-1">{desc}</p>}
      </div>
      {href && (
        <Link href={href}>
          <Button variant="ghost" size="sm">
            Xem tất cả →
          </Button>
        </Link>
      )}
    </div>
  );
}
