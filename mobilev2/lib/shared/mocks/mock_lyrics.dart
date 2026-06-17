import 'package:karaoke/shared/models/lyric_line.dart';
import 'package:karaoke/shared/utils/lrc_parser.dart';

const String mockLrcContent = '''
[00:00.00]Hoa Nở Không Màu - Hoài Lâm
[00:08.50]Sáng tác: Nguyễn Minh Cường
[00:18.20]Em là hoa nở không màu
[00:22.50]Anh là gió đi qua đời
[00:27.80]Trong khoảnh khắc đó vô tình
[00:32.40]Anh đã cướp đi hương em
[00:40.00]Hoa nở không màu vẫn đẹp
[00:44.50]Tình anh nồng nàn vẫn xa
[00:49.20]Bao yêu thương em dành cho anh
[00:54.00]Giờ chỉ còn lại bão giông
[01:02.00]Đời em như cánh hoa rơi
[01:06.80]Theo gió cuốn về nơi đâu
[01:11.50]Anh đã quên rồi sao?
[01:15.80]Những lời thề ngày xưa
[01:23.50]Em không trách anh đâu
[01:28.00]Chỉ tại duyên ta không thành
[01:32.80]Em chỉ là cơn mưa
[01:37.50]Vội đi qua đời anh
[01:45.20]Hoa nở không màu vẫn đẹp
[01:49.80]Dù chẳng ai biết đến tên
[01:54.50]Em vẫn yêu anh như ngày đầu
[01:59.20]Dẫu biết là đã muộn rồi
[02:08.00]La la la la la
[02:12.50]La la la la la
[02:17.00]Em là hoa nở không màu...
''';

final List<LyricLine> mockLyrics = parseLrc(mockLrcContent);
