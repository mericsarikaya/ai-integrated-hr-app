import cds from '@sap/cds';

cds.on('bootstrap', (app) => {
    
    // 1. ÇIKIŞ YAPMA ROTASI (Buraya gelen herkes koşulsuz şifresini kaybeder)
    app.use('/logout', (req, res) => {
        // Tarayıcı şifreyi reddettiğimizi görünce popup çıkaracak. Kullanıcı "İptal" dediğinde bu ekranı görecek:
        res.status(401).send(`
            <div style="text-align:center; padding:50px; font-family:sans-serif; background:#0f172a; color:white; height:100vh;">
                <h2>Başarıyla çıkış yapıldı.</h2>
                <p>Güvenliğiniz için tarayıcınızdaki şifre temizlendi.</p>
                <button onclick="window.location.href='/'" style="padding:10px 20px; font-size:16px; cursor:pointer;">Ana Sayfaya Dön (Yeniden Giriş Yap)</button>
            </div>
        `);
    });

    // 2. ANA SAYFA KORUMASI
    app.use((req, res, next) => {
        if (req.path === '/' || req.path.startsWith('/index.html')) {
            if (!req.headers.authorization) {
                res.setHeader('WWW-Authenticate', 'Basic realm="HR Hub Sistemi"');
                return res.status(401).send('Giriş yapmanız gerekiyor.');
            }
        }
        next();
    });
});

export default cds.server;