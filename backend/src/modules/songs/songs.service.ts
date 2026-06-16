import { Injectable } from '@nestjs/common';
import { SongResult, YoutubeService } from './youtube.service';

@Injectable()
export class SongsService {
  constructor(private readonly youtube: YoutubeService) {}

  /// Tìm bài hát. Hiện uỷ quyền trực tiếp cho YouTube; sau này có thể thêm
  /// cache Redis (giảm quota) + lưu bảng Song cho trending/history.
  search(q: string, maxResults = 20): Promise<SongResult[]> {
    return this.youtube.search(q, maxResults);
  }
}
