import cds from '@sap/cds';
import express from 'express';

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
    
    // 3. İŞTE ŞİFRE KONTROLÜNÜN VERİTABANINDAN YAPILDIĞI YER
    app.use(async (req, res, next) => {
        const authBase64 = req.cookies?.hr_session || (req.headers.authorization ? req.headers.authorization.split(' ')[1] : null);
        if (!authBase64) return next();

        const [username, password] = Buffer.from(authBase64, 'base64').toString().split(':');

        try {
            const users = await cds.db.read('hr.app.Passwords').where({ authorizationPerson: username });
            const dbUser = users[0];

            if (dbUser && dbUser.password === password) {
                
                // Rolü belirle
                let userRole = 'Candidate';
                if (username === 'ik') userRole = 'HRAdmin';
                if (username === 'calisan') userRole = 'Employee';

                // CDS'in mocked auth'unun tanıyacağı kullanıcı bilgilerini header'a yaz
                // Bu sayede CDS rolü doğru atayacak ve Fiori butonları doğru gösterecek
                const mockedMap = {
                    'HRAdmin':  'ik:3',
                    'Employee': 'calisan:2',
                    'Candidate': 'aday:1'
                };
                req.headers.authorization = `Basic ${Buffer.from(mockedMap[userRole]).toString('base64')}`;
                next();

            } else {
                res.status(401).send('Kullanıcı adı veya şifre hatalı!');
            }
        } catch (error) {
            console.error("Veritabanından şifre kontrolü yapılırken hata:", error);
            res.status(500).send('Sistem Hatası');
        }
    });

// Kayıt Olma Endpoint
 app.post('/register', express.json(), async (req, res) => {
     try {
         const { username, password } = req.body;
         if (!username || !password) {
             return res.status(400).send('Kullanıcı adı ve şifre zorunludur.');
         }
         
         // Veritabanında bu kullanıcı adı zaten var mı diye kontrol ediyoruz
         const existingUsers = await cds.db.read('hr.app.Passwords').where({ authorizationPerson: username });
         if (existingUsers.length > 0) {
             return res.status(400).send('Bu kullanıcı adı zaten alınmış.');
         }

         // HANA (veya SQLite) veritabanına yeni kişiyi ekliyoruz.
         await cds.db.run(
         cds.ql.INSERT.into('hr.app.Passwords').entries({
             authorizationPerson: username,
             password: password
         })
        );

         res.status(201).send('Kayıt başarılı.');
     } catch (error) {
         console.error("Kayıt sırasında hata:", error);
         res.status(500).send('Sunucu hatası oluştu.');
     }
 });

});

export default cds.server;