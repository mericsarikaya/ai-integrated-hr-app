import fs from 'fs';
import path from 'path';

function copyDir(src, dest) {
    if (!fs.existsSync(dest)) {
        fs.mkdirSync(dest, { recursive: true });
    }
    let entries = fs.readdirSync(src, { withFileTypes: true });
    
    for (let entry of entries) {
        let srcPath = path.join(src, entry.name);
        let destPath = path.join(dest, entry.name);
        
        if (entry.isDirectory()) {
            copyDir(srcPath, destPath);
        } else {
            // .cds uzantılı dosyaları ATLA, diğerlerini (html, css, js) kopyala!
            if (!srcPath.endsWith('.cds')) {
                fs.copyFileSync(srcPath, destPath);
            }
        }
    }
}

// app klasörünü gen/srv/app içine kopyala
copyDir('app', 'gen/srv/app');
console.log("Arayüz dosyaları (.cds dosyaları hariç) başarıyla taşındı.");
