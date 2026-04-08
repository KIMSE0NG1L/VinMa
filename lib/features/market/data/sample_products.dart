import '../domain/product.dart';

const productCategories = ['전체', '구두', '로퍼', '부츠', '스니커즈', '의류'];

const sampleProducts = [
  Product(
    id: 1,
    name: '크로켓앤존스 첼시 옥스포드 UK8',
    price: 280000,
    category: '구두',
    condition: '상',
    imageUrl:
        'https://images.unsplash.com/photo-1673201183138-e68d0b47dbe5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
    brand: '크로켓앤존스',
    size: 'UK8',
    description: '클래식한 실루엣의 옥스포드 슈즈입니다. 포멀한 착장과 데일리 클래식 룩에 잘 어울립니다.',
  ),
  Product(
    id: 2,
    name: '크로켓앤존스 코도반 로퍼',
    price: 450000,
    category: '로퍼',
    condition: '상',
    imageUrl:
        'https://images.unsplash.com/photo-1593030977498-ef2db97e564e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
    brand: '크로켓앤존스',
    size: '미상',
    description: '광택감 있는 코도반 무드의 로퍼입니다. 상태가 좋아 오래 소장하기 좋은 피스입니다.',
  ),
  Product(
    id: 3,
    name: '크로켓앤존스 태슬 로퍼 UK8',
    price: 320000,
    category: '로퍼',
    condition: '중',
    imageUrl:
        'https://images.unsplash.com/photo-1765871903745-804b6d83324c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
    brand: '크로켓앤존스',
    size: 'UK8',
    description: '태슬 디테일이 있는 로퍼입니다. 자연스러운 사용감이 있는 빈티지 컨디션입니다.',
  ),
  Product(
    id: 4,
    name: 'JM 웨스턴 스트레이트 팁 옥스포드 8E',
    price: 680000,
    category: '구두',
    condition: '상',
    imageUrl:
        'https://images.unsplash.com/photo-1590426987126-d4290aaedc72?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
    brand: 'JM 웨스턴',
    size: '8E',
    description: '견고한 구조감이 돋보이는 드레스 슈즈입니다. 클래식 슈즈를 좋아하는 분에게 잘 맞습니다.',
  ),
  Product(
    id: 5,
    name: '브루넬로 쿠치넬리 부츠 42',
    price: 1250000,
    category: '부츠',
    condition: '상',
    imageUrl:
        'https://images.unsplash.com/photo-1573688886816-d0072f2b8b77?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
    brand: '브루넬로 쿠치넬리',
    size: '42',
    description: '차분한 고급감이 있는 부츠입니다. 겨울 아우터와 함께 활용하기 좋습니다.',
  ),
  Product(
    id: 6,
    name: '벨루티 첼시 부츠 8.5',
    price: 1800000,
    category: '부츠',
    condition: '상',
    imageUrl:
        'https://images.unsplash.com/photo-1608629601270-a0007becead3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
    brand: '벨루티',
    size: '8.5',
    description: '브랜드 특유의 존재감이 있는 첼시 부츠입니다. 희소성과 소장 가치가 돋보입니다.',
  ),
  Product(
    id: 7,
    name: '안드레아 벤추라 럭셔리 스니커즈',
    price: 420000,
    category: '스니커즈',
    condition: '상',
    imageUrl:
        'https://images.unsplash.com/photo-1701321584208-653fa267cf01?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
    brand: '안드레아 벤추라',
    size: '42',
    description: '가벼운 착장에 매치하기 좋은 프리미엄 스니커즈입니다.',
  ),
  Product(
    id: 8,
    name: '프라다 리버시블 카디건',
    price: 780000,
    category: '의류',
    condition: '중',
    imageUrl:
        'https://images.unsplash.com/photo-1607085941350-7d46c83aa9f5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
    brand: '프라다',
    size: '42',
    description: '두 가지 분위기로 활용할 수 있는 리버시블 카디건입니다. 사용감은 있으나 착용에는 무리 없습니다.',
  ),
];
