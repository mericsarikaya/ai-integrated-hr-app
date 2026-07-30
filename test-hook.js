const cds = require('@sap/cds');
(async function() {
    const srv = await cds.serve('HRService').from('srv/service');
    let triggered = false;
    srv.before('NEW', 'HRService.MyApplications', (req) => {
        triggered = true;
        console.log('NEW MyApplications triggered!');
    });
    
    // simulate new
    const req = { event: 'NEW', entity: 'HRService.MyApplications', data: {} };
    await srv.emit(req);
    console.log('Triggered:', triggered);
})();
