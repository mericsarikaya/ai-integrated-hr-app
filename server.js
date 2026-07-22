import cds from '@sap/cds';

cds.on('bootstrap', (app) => {

    // 0. BEYAZ POPUP'I SONSUZA DEK YOK ETME SİHRİ
    app.use((req, res, next) => {
        const originalSetHeader = res.setHeader;
        res.setHeader = function(name, value) {
            if (name.toLowerCase() === 'www-authenticate') {
                return; // Tarayıcının popup çıkarmasını sağlayan emri çöpe at!
            }
            return originalSetHeader.call(this, name, value);
        };
        next();
    });
    
    // 1. Çerezleri Okuma
    app.use((req, res, next) => {
        if (req.headers.cookie) {
            req.cookies = req.headers.cookie.split(';').reduce((acc, cookie) => {
                const [key, value] = cookie.trim().split('=');
                acc[key] = value;
                return acc;
            }, {});
        }
        next();
    });

    // 2. Korumalı Sayfa Yönlendirmesi (Çerezi veya şifresi olmayanları login.html'e fırlat)
    app.use((req, res, next) => {
        if (req.path === '/' || req.path.startsWith('/index.html') || req.path.startsWith('/hr')) {
            if (!req.cookies?.hr_session && !req.headers.authorization) {
                return res.redirect('/login.html');
            }
        }
        next();
    });

    // 3. İŞTE ŞİFRE KONTROLÜNÜN VERİTABANINDAN YAPILDIĞI YER (Sizin Algoritmanız)
    app.use(async (req, res, next) => {
        // Çerezden veya login sayfasından gelen şifreyi yakala
        const authBase64 = req.cookies?.hr_session || (req.headers.authorization ? req.headers.authorization.split(' ')[1] : null);
        if (!authBase64) return next();

        // Gelen şifreyi çöz (Örn: ik ve 3)
        const [username, password] = Buffer.from(authBase64, 'base64').toString().split(':');

        try {
            // HANA (veya SQLite) VERİTABANINA BAĞLAN VE KİŞİYİ BUL
            const users = await cds.db.read('hr.app.Passwords').where({ authorizationPerson: username });
            const dbUser = users[0];

            // Veritabanında kişi var mı ve şifresi doğru mu?
            if (dbUser && dbUser.password === password) {
                
                // ŞİFRE DOĞRU! Rolleri belirle ve içeri al
                let userRole = 'Candidate'; // Varsayılan rol
                if (username === 'ik') userRole = 'HRAdmin';
                if (username === 'calisan') userRole = 'Employee';

                // SAP sistemine bu kişinin kimliğini tanımla
                req.user = new cds.User({ id: username, roles: [userRole] });
                delete req.headers.authorization;
                next(); // Kapıyı aç

            } else {
                // Şifre yanlışsa anında engelle
                res.status(401).send('Kullanıcı adı veya şifre hatalı!');
            }
        } catch (error) {
            console.error("Veritabanından şifre kontrolü yapılırken hata:", error);
            res.status(500).send('Sistem Hatası');
        }
    });
});

export default cds.server;