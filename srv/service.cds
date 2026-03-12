using my.enterprise from '../db/schema';
// BAdI dosyamızın yerini zorla gösteriyoruz!
@impl: './service.js'
service SalesService {
  // Dış dünyaya açacağımız entity'ler
  @odata.draft.enabled
  entity Orders as projection on enterprise.SalesOrders;
  entity OrderItems as projection on enterprise.SalesOrderItems;
}


// ---- FIORI EKRAN TASARIMI (UI ANNOTATIONS) ----
annotate SalesService.Orders with @(
    UI: {
        HeaderInfo: {
            TypeName: 'Sipariş',
            TypeNamePlural: 'Siparişler'
        },
        SelectionFields: [ orderNo, buyerName ],
        
        // 1. ANA EKRAN (Liste/Tablo) Tasarımı
        LineItem: [
            { Value: orderNo, Label: 'Sipariş No' },
            { Value: buyerName, Label: 'Müşteri' },
            { Value: grossAmount, Label: 'Tutar' },
            { Value: currency, Label: 'Para Birimi' }
        ],
        
        // 2. DETAY EKRANI (Object Page / Form) Tasarımı
        Facets: [
            {
                $Type: 'UI.ReferenceFacet',
                Label: 'Sipariş Başlık Bilgileri', // Formun üst başlığı
                Target: '@UI.FieldGroup#Main' // Formun içindeki alanları nereden alacağını söyler
            }
        ],
        
        // Formun içindeki gerçek giriş alanları
        FieldGroup #Main: {
            Data: [
                { Value: orderNo, Label: 'Sipariş No' },
                { Value: buyerName, Label: 'Müşteri Adı' },
                { Value: grossAmount, Label: 'Toplam Tutar' },
                { Value: currency, Label: 'Para Birimi' }
            ]
        }
    }
);