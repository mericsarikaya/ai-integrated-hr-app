# AI Integrated HR App

  SAP CAP (Cloud Application Programming Model) tabanlı, yapay zeka destekli İnsan Kaynakları yönetim uygulaması. İşe
alım, çalışan yönetimi, performans değerlendirme, izin takibi ve HR chatbot gibi süreçleri tek bir platformda
birleştirir.

  ## Özellikler

  - **İşe Alım (Recruitment)**: İlan yayınlama, adayların CV yükleyip başvurması, AI ile CV analizi (eğitim skoru,
güçlü/zayıf yönler, dil becerileri) ve aday değerlendirme/onay süreci
  - **Çalışan Yönetimi**: Departman, pozisyon, yetkinlik (skill) ve organizasyon yapısı (yönetici/direct report) takibi
  - **Performans Yönetimi**: Performans değerlendirmeleri, hedef (goal) takibi ve ilerleme yönetimi
  - **Attrition Risk (İşten Ayrılma Riski)**: Çalışan bazlı risk skoru hesaplama, risk seviyesi geçmişi ve önerilen
aksiyonlar
  - **Yıllık İzin (Annual Leave)**: İzin talebi oluşturma, onaylama/reddetme akışı (draft-enabled)
  - **Anket & Duygu Analizi**: Çalışan anketleri, AI destekli sentiment/tema analizi
  - **HR Chatbot**: Google Generative AI (Gemini) entegrasyonu ile çalışan/adaylara soru-cevap desteği (`askHRBot`)
  - **Analitik Dashboard**: Departman istatistikleri, risk dağılımı, işe alım hunisi ve performans trendi için salt-
okunur analytics servisi
  - **Rol Bazlı Yetkilendirme**: `Candidate`, `Employee`, `HRAdmin` rolleriyle servis/entity seviyesinde erişim kontrolü

  ## Teknoloji Yığını

  - **Backend**: [SAP Cloud Application Programming Model (CAP)](https://cap.cloud.sap) – Node.js
  - **Veritabanı**: SQLite (geliştirme), SAP HANA (production/hybrid)
  - **Kimlik Doğrulama**: SAP XSUAA (`@sap/xssec`), geliştirmede mocked auth
  - **AI**: Google Generative AI (`@google/generative-ai`), PDF ayrıştırma (`pdf-parse`)
  - **UI**: Fiori Elements önizleme + statik HTML sayfaları (`app/`)
  - **Deployment**: Multi-Target Application (MTA) - Cloud Foundry

  ## Proje Yapısı
```
app/                        UI (Fiori annotations + statik HTML sayfaları)
  ├── chatbot.html
  ├── login.html
  ├── register.html
  ├── myapplications.html
  ├── index.html
  ├── recruitment/
  │   └── annotations.cds
  ├── job_postings/
  │   └── annotations.cds
  ├── employees/
  │   └── annotations.cds
  ├── annual_leave/
  │   └── annotations.cds
  └── router/                 App Router
      └── xs-app.json
  db/
  └── schema.cds              Domain modeli (Employees, Candidates, JobPostings, ...)

  srv/
  ├── service.cds             HRService - ana iş servisi
  ├── service.js
  ├── analytics.cds           AnalyticsService - dashboard/istatistik servisi
  └── analytics.js

  test/
  └── api.http                Manuel API testleri

  mta.yaml                    Cloud Foundry deployment tanımı
  package.json

  ## Kurulum

  ```
bash
  npm install

## Çalıştırma (Geliştirme)

  npm start
  # veya
  cds watch

Uygulama varsayılan olarak  http://localhost:4004  üzerinde ayağa kalkar.

### Test Kullanıcıları (mocked auth)

 Kullanıcı                              │ Şifre                                 │ Rol
────────────────────────────────────────┼───────────────────────────────────────┼───────────────────────────────────────
 aday                                   │ 1                                     │ Candidate
 calisan                                │ 2                                     │ Employee
 ik                                     │ 3                                     │ HRAdmin

## Servisler

•  /hr  — HRService: Çalışan, departman, işe alım, performans, izin ve chatbot işlemleri
•  /analytics  — AnalyticsService: Salt okunur dashboard/istatistik view'ları

## Ortam Değişkenleri

AI entegrasyonu için Google Generative AI API anahtarı  .env  dosyasında tanımlanmalıdır ( dotenv  ile yüklenir):

  GEMINI_API_KEY=...

## Deployment (Cloud Foundry)

  mbt build
  cf deploy mta_archives/hr-app_1.0.0.mtar

 mta.yaml  içinde  hr-app-srv  (Node.js servis),  hr-app-db-deployer  (HDI container) ve  hr-app  (App Router) modülleri
tanımlıdır.

## Lisans

Bu proje özel/eğitim amaçlıdır.
