# SAP CAP with SAP HANA Cloud (Sales Order Scenario)

Bu proje, SAP Cloud Application Programming (CAP) modeli kullanılarak geliştirilmiş, gerçek bir SAP HANA Cloud veritabanına bağlı ve Fiori Elements (Draft destekli) arayüzüne sahip bir Sipariş (Sales Order - VBAK) uygulamasıdır. 

Lokalde Node.js ile geliştirilmiş, veritabanı olarak SAP BTP üzerindeki HANA Cloud kullanılmıştır (Hybrid Test).

## ☁️ SAP BTP Tarafında Yapılan Kurulumlar (Adım Adım)

Bu projenin çalışabilmesi için SAP BTP (Business Technology Platform) üzerinde aşağıdaki mimari altyapı sırasıyla kurulmuştur:

1. **HANA Database Instance Yaratılması:**
   - SAP HANA Cloud Central üzerinden `trial_cap_db` adında yeni bir HANA DB ayağa kaldırıldı.
2. **Instance Mapping (Çalışma Alanı Eşleştirmesi):**
   - *Sorun:* BTP üzerindeki `dev` çalışma alanı (Cloud Foundry Space), HANA veritabanını göremiyordu.
   - *Çözüm:* HANA DB ayarlarından **Manage Instance Mapping** ekranına gidilip, veritabanı ile Cloud Foundry'deki `dev` space'i birbirine bağlandı.
3. **Firewall (Güvenlik Duvarı) İzni:**
   - *Sorun:* Lokal VS Code terminalimizden veritabanına bağlanıp tabloları basmaya (`cds deploy`) çalışırken 443 portu/Soket koptu hatası alındı.
   - *Çözüm:* HANA DB **Connections** ayarlarından `"Allow all IP addresses"` seçilerek, lokal bilgisayarımızın bulut veritabanına veri yazabilmesinin önü açıldı.
4. **Zombi Servislerin Temizliği:**
   - İlk hatalı deploy denemelerinden kalan bozuk servisleri temizlemek için Cloud Foundry CLI üzerinden `cf delete-service cap_with_hana_db-db -f` komutu ile ortam steril hale getirildi.

## 💻 VS Code Üzerinde Kullanılan Komutlar ve Açıklamaları

Projenin başlatılmasından, HANA'ya deploy edilmesine kadar aşağıdaki CLI komutları kullanılmıştır:

* `cds init cap_with_hana_db`
    * *Açıklama:* Projenin iskeletini (db, srv, app klasörlerini ve package.json'ı) oluşturur.
* `cds add hana`
    * *Açıklama:* Projeye SAP HANA veritabanı yeteneği kazandırır. `package.json` içine HANA yapılandırmasını ekler.
* `npm install @cap-js/hana`
    * *Açıklama:* Node.js sunucusunun HANA ile konuşabilmesi için gereken veritabanı sürücüsünü (driver) projeye indirir.
* `cf login`
    * *Açıklama:* VS Code terminalinden SAP BTP Cloud Foundry ortamına (Space) güvenli giriş yapmamızı sağlar.
* `cds deploy --to hana`
    * *Açıklama:* `db/schema.cds` içindeki veri modelimizi (DDIC tabloları) alır, BTP'deki HANA veritabanına bağlanır ve bizim için izole bir HDI Container (Şema) açıp `CREATE TABLE` komutlarını çalıştırarak tabloları fiziksel olarak yaratır.
* `cds watch --profile hybrid`
    * *Açıklama:* Node.js sunucusunu lokalde (`localhost:4004`) başlatır ancak geçici SQLite yerine **doğrudan BTP üzerindeki gerçek HANA veritabanına** tünel açarak bağlanır (Hybrid mode). Kod (JS/CDS) her değiştiğinde kendini otomatik yeniler.

## 🧠 Öne Çıkan Geliştirmeler

* **Fiori Draft Altyapısı:** `srv/service.cds` dosyasında `@odata.draft.enabled` kullanılarak Fiori V4 Taslak mimarisi aktif edilmiştir.
* **Custom Handler (BAdI / User Exit):** `srv/service.js` dosyasında OData V4 eventlerine (`NEW`, `CREATE`) müdahale edilmiş; kullanıcı "Oluştur" butonuna bastığı an, sistem HANA'ya sorgu atıp sıradaki **Sipariş Numarasını (SNRO mantığı)** otomatik olarak hesaplayıp form üzerine basmaktadır.

## 🚀 SAP BTP Trial Hesabı Açma ve İlk Ayarlar (Sıfırdan Başlayanlar İçin)

> ⚠️ **ÖNEMLİ NOT:** SAP, BTP (Business Technology Platform) arayüzlerini, menü yerlerini ve Trial (Deneme) hesabı prosedürlerini çok sık güncellemektedir. Aşağıdaki adımlar geliştirme yapıldığı tarih itibarıyla geçerlidir ancak zamanla ekranlar veya buton isimleri değişiklik gösterebilir. Ana mantık her zaman aynıdır: *Bir hesap aç, Cloud Foundry'yi aktifleştir, HANA veritabanını yarat ve dışarıdan (lokalden) erişime aç.*

Bu projeyi kendi ortamınızda ayağa kaldırmak için sıfırdan yapmanız gereken BTP ayarları şunlardır:

### 1. Trial Hesabının Oluşturulması
1. [SAP BTP Trial](https://account.hanatrial.ondemand.com/) adresine gidin ve ücretsiz SAP ID'niz ile kayıt olun.
2. İlk girişte sistem sizin için otomatik olarak bir **Global Account** ve bunun altında bir **Subaccount** (Örn: *trial*) oluşturur. (Bölge olarak genelde *US10 - US East* veya *EU10* seçilir).

### 2. Cloud Foundry (CF) Ortamının Hazırlanması
1. Oluşturulan Subaccount'un (trial) içine girin.
2. Ekranda **Enable Cloud Foundry** (Cloud Foundry'yi Aktifleştir) butonuna tıklayın.
3. Sistem size benzersiz bir **Org Name** (Organizasyon ID, örn: `x9999xx9trial`) atayacak ve varsayılan olarak `dev` adında bir **Space** (Çalışma Alanı) yaratacaktır. Uygulamamız bu `dev` alanında koşacaktır.

### 3. SAP HANA Cloud Veritabanının Kurulması
1. Sol menüden **Instances and Subscriptions** sekmesine tıklayın.
2. Sağ üstten **Create** (Oluştur) butonuna basarak yeni bir servis yaratma ekranını açın.
3. Servis olarak **SAP HANA Cloud**'u seçin ve *SAP HANA Database* tipinde bir instance yaratın.
    * **Instance Name:** `trial_cap_db` (İstediğiniz ismi verebilirsiniz).
    * **Plan:** 'tools' seçin.
    * **Administrator Password:** Veritabanı admini (`DBADMIN`) için güçlü bir şifre belirleyin ve unutmayın.
4. 🛑 **KRİTİK ADIM (Güvenlik Duvarı):** Kurulum sihirbazındaki *Connections* (Bağlantılar) adımında varsayılan ayar sadece BTP içine izin verir. Lokal bilgisayarınızdan (VS Code üzerinden) bu veritabanına bağlanıp tablo basabilmek için bu ayarı kesinlikle **"Allow all IP addresses"** (Tüm IP adreslerine izin ver) olarak değiştirin.
5. Kurulumu tamamlayın. Veritabanının durumunun `CREATING`'den `RUNNING`'e geçmesi yaklaşık 10-15 dakika sürebilir.

### 4. Instance Mapping (HANA ile Cloud Foundry'yi Birbirine Bağlamak)
*Veritabanı ayağa kalktıktan sonra yapılması zorunlu olan, en çok hata alınan ("There is no database available" hatası) adımdır.*
1. HANA veritabanınız `RUNNING` durumundayken en sağındaki **üç noktaya (...)** tıklayın.
2. **Manage Instance Mapping** seçeneğini seçin.
3. Açılan yan panelde **Environment:** `Cloud Foundry`, **Organization:** *(Kendi Org ID'niz)* ve **Space:** `dev` olarak seçip eşleştirmeyi kaydedin. 

Artık veritabanınız VS Code üzerinden gelecek `cds deploy --to hana` komutlarını karşılamaya ve tablolarınızı oluşturmaya hazırdır!
