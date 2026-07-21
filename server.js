import cds from '@sap/cds';

cds.on('bootstrap', (app) => {
    // Sayfa ilk açıldığında (index.html) tarayıcının kendi şifre ekranını (Basic Auth) zorla
    app.use((req, res, next) => {
        if (req.path === '/' || req.path.startsWith('/index.html')) {
            if (!req.headers.authorization) {
                res.setHeader('WWW-Authenticate', 'Basic realm="HR Hub Sistemi"');
                return res.status(401).send('Sisteme erişmek için sayfayı yenileyip giriş yapmalısınız.');
            }
        }
        next();
    });
});

export default cds.server;