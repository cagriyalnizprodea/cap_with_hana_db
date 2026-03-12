namespace my.enterprise;

// Sipariş Başlık Tablosu (VBAK muadili)
entity SalesOrders {
  key ID       : UUID;          // Otomatik üretilen eşsiz anahtar
  orderNo      : String(10) @Core.Computed;    // Sipariş Numarası (VBELN)
  buyerName    : String(100);   // Müşteri Adı
  currency     : String(3);     // Para Birimi (WAERK)
  grossAmount  : Decimal(15, 2); // Toplam Tutar (NETWR)
  
  // Kalemlere olan güçlü bağlantı (Header silinirse Items da silinir)
  items        : Composition of many SalesOrderItems on items.parent = $self;
}

// Sipariş Kalem Tablosu (VBAP muadili)
entity SalesOrderItems {
  key ID       : UUID;
  parent       : Association to SalesOrders; // Başlığa referans
  itemNo       : Integer;       // Kalem No (POSNR)
  material     : String(40);    // Malzeme (MATNR)
  quantity     : Integer;       // Miktar (KWMENG)
}