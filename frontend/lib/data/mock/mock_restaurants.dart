import '../../core/constants/app_assets.dart';
import '../models/restaurant.dart';

const mockRestaurants = [
  Restaurant(
    name: 'Phở Tư Lùn Ấu Triệu',
    imagePath: AppAssets.phoBo,
    rating: 4.7,
    distanceKm: 0.2,
    tags: ['Món nước', 'Đặc sản Hà Nội'],
  ),
  Restaurant(
    name: 'Bún Bò Huế Nam Minh',
    imagePath: AppAssets.bunBo,
    rating: 4.7,
    distanceKm: 1.2,
    tags: ['Món nước', 'Đặc sản Huế'],
  ),
];