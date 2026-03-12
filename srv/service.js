module.exports = function(srv) {
    
    srv.before(['NEW', 'CREATE'], 'Orders', async (req) => {
        console.log("💥 BAdI ÇALIŞTI! Olay:", req.event);
        
        // Eğer orderNo zaten doluysa (güncelleme yapılıyorsa) numarayı bozma!
        // Sadece boşsa yeni numara ver.
        if (!req.data.orderNo) {
            const { Orders } = srv.entities;
            
            // HANA'ya git ve en büyük numarayı sor
            const result = await SELECT.one.from(Orders).columns('max(orderNo) as maxID');
            
            let nextNo = 1000; 
            if (result && result.maxID) {
                // Eğer içeride 9999 gibi manuel denemelerimiz varsa ondan devam eder :)
                nextNo = parseInt(result.maxID, 10) + 1;
            }
            
            req.data.orderNo = nextNo.toString();
            console.log("📈 Gerçek Numara Atandı:", req.data.orderNo);
        }
    });
    
};