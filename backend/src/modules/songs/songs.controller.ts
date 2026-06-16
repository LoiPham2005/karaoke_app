import { Controller, Get, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../../common/decorators/public.decorator';
import { SearchSongsDto } from './dto/search-songs.dto';
import { SongsService } from './songs.service';

@ApiTags('songs')
@Controller('songs')
export class SongsController {
  constructor(private readonly songs: SongsService) {}

  /// GET /api/v1/songs/search?q=&maxResults=
  /// Public — dùng ở màn search (chưa cần đăng nhập).
  @Public()
  @Get('search')
  @ApiOperation({ summary: 'Tìm bài hát từ YouTube' })
  search(@Query() dto: SearchSongsDto) {
    return this.songs.search(dto.q, dto.maxResults);
  }
}
