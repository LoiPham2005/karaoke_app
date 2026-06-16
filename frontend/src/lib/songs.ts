import type { Song } from '@/types';
import { apiGet } from './api';

/// Tìm bài hát từ YouTube qua backend. GET /songs/search?q=&maxResults=
export function searchSongs(
  q: string,
  maxResults = 20,
  signal?: AbortSignal,
): Promise<Song[]> {
  const params = new URLSearchParams({ q, maxResults: String(maxResults) });
  return apiGet<Song[]>(`/songs/search?${params.toString()}`, signal);
}
