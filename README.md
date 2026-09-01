# Aýterek Master

Aýterek platformasynyň hyzmat ýerine ýetirijiler (ussalar) üçin Flutter bilen ýazylan mobil goşundysy.

📲 Google Play: https://play.google.com/store/apps/details?id=com.ayterek.ussalar

## Näme üçin?

"Aýterek" ulgamynda (aýry-aýry müşderi goşundysynda) döredilen ýumuşlara ussalar hökmünde teklip bermäge we dürli işleri ýerine ýetirmäge mümkinçilik berýän goşundy. Ulanyjylar öz anketalaryny doldurup ýerine ýetiriji bolýarlar we şu kategoriýalardaky sargytlary ýerine ýetirip pul gazanýarlar:

- Abatlaýyş, santehnika, elektrika
- Mebel
- Gözellik
- Repetitorlyk
- Çaparlyk / ýük daşamak
- Arassaçylyk
- we beýleki dürli hyzmat kategoriýalary

Ussalar işleri welaýat we kategoriýa boýunça filtrläp, özlerine amatly sargytlary saýlap bilýärler. Iş tamamlanandan soň müşderiler ýerine ýetirilen işi bahalandyryp, teswir galdyryp bilýärler.

## Tehnologiýalar

- **Flutter** (Dart SDK >=3.5.0)
- **GetX** — state management, routing, dependency injection
- **Firebase** — Core, Cloud Messaging, Analytics
- **Socket.IO / WebSocket** — real-time çat we bildirişler
- **flutter_map** — kartada iş ýerlerini görkezmek
- **Dio** — network gatnaşyklary we cache

## Proýektiň gurluşy

```
lib/
├── core/           # init, services, controllers, models, theme
├── shared/         # umumy widget, dialog, extension, constants
└── modules/        # her ekran/aýratynlyk boýunça modullar
    ├── splash
    ├── onboarding
    ├── login
    ├── bottomnavbar
    ├── all              # ähli ýumuşlaryň sanawy
    ├── filter_view      # ýumuşlary filtrlemek
    ├── task             # ýumuş detaly
    ├── chats            # müşderi bilen çat
    ├── special_profile  # ussanyň profili
    └── settings_profile # sazlamalar
```

## Işe girizmek

```bash
flutter pub get
flutter run
```
