'use client';

import { useState } from 'react';
import { Search as SearchIcon, X, Clock, Filter, LayoutGrid, List } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { SongCard } from '@/components/songs/SongCard';
import { SongRow } from '@/components/songs/SongRow';
import { mockSongs } from '@/mocks/songs';
import { cn } from '@/lib/utils';

const filters = ['Tất cả', 'Karaoke', 'Có lời', 'Không lời', 'Beat', 'Demo'];
const recentSearches = ['Hoa nở không màu', 'Sơn Tùng', 'Bolero buồn', 'Despacito', 'See you again'];

export default function SearchPage() {
  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState('Tất cả');
  const [view, setView] = useState<'grid' | 'list'>('grid');

  const results = query ? mockSongs : mockSongs;

  return (
    <div className="container py-6 space-y-6">
      {/* Search Header */}
      <div className="space-y-4">
        <div className="relative">
          <SearchIcon className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
          <Input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Tìm bài hát, ca sĩ, playlist..."
            className="pl-12 pr-12 h-14 text-base rounded-2xl"
            autoFocus
          />
          {query && (
            <Button
              size="icon-sm"
              variant="ghost"
              className="absolute right-3 top-1/2 -translate-y-1/2"
              onClick={() => setQuery('')}
            >
              <X className="h-4 w-4" />
            </Button>
          )}
        </div>

        {/* Filter chips */}
        <div className="flex items-center gap-2 overflow-x-auto pb-2">
          {filters.map((f) => (
            <Badge
              key={f}
              variant={filter === f ? 'default' : 'outline'}
              className="cursor-pointer px-4 py-1.5 text-sm shrink-0"
              onClick={() => setFilter(f)}
            >
              {f}
            </Badge>
          ))}
          <div className="ml-auto flex items-center gap-1 shrink-0">
            <Button size="icon-sm" variant="ghost">
              <Filter className="h-4 w-4" />
            </Button>
            <div className="flex bg-card rounded-lg p-0.5">
              <Button
                size="icon-sm"
                variant={view === 'grid' ? 'secondary' : 'ghost'}
                onClick={() => setView('grid')}
              >
                <LayoutGrid className="h-4 w-4" />
              </Button>
              <Button
                size="icon-sm"
                variant={view === 'list' ? 'secondary' : 'ghost'}
                onClick={() => setView('list')}
              >
                <List className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Empty / Recent / Results */}
      {!query ? (
        <div>
          <h3 className="text-sm font-semibold text-muted-foreground mb-3 flex items-center gap-2">
            <Clock className="h-4 w-4" />
            Tìm kiếm gần đây
          </h3>
          <div className="flex flex-wrap gap-2">
            {recentSearches.map((s) => (
              <button
                key={s}
                onClick={() => setQuery(s)}
                className="px-4 py-2 rounded-full bg-card hover:bg-accent text-sm transition-colors"
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      ) : (
        <div>
          <p className="text-sm text-muted-foreground mb-4">
            Tìm thấy <span className="font-semibold text-foreground">{results.length}</span> kết quả
            cho &quot;{query}&quot;
          </p>
          {view === 'grid' ? (
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
              {results.map((song) => (
                <SongCard key={song.youtubeId} song={song} />
              ))}
            </div>
          ) : (
            <div className="bg-card rounded-2xl p-3 space-y-1">
              {results.map((song, idx) => (
                <SongRow key={song.youtubeId} song={song} index={idx + 1} />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
