// Güvenli geri navigasyon yardımcısı
//
// Sorun: Ekranlar context.go() ile açılınca yığın sıfırlanıyordu; ardından
// context.pop() çağrıldığında geri dönülecek sayfa olmadığı için GoRouter hata
// veriyor ya da Android geri tuşu uygulamayı kapatıyordu.
// Çözüm: Hiyerarşik ekranlar push ile açılır; geri dönüşte yığında sayfa yoksa
// (ör. derin bağlantı / yeniden başlatma) mantıklı bir üst ekrana gidilir.

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension SafeNavigation on BuildContext {
  /// Yığında önceki sayfa varsa ona dön, yoksa [fallback] rotasına git.
  void popOrGo(String fallback) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}
