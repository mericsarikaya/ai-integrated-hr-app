const axios = require('axios');
async function test() {
    try {
        const headers = { 'x-custom-userid': 'DU', 'Content-Type': 'application/json' };
        
        console.log('1. Creating Draft...');
        let res = await axios.post('http://localhost:4004/hr/MyApplications', {}, { headers });
        const draftId = res.data.ID;
        console.log('Draft created with ID:', draftId);

        console.log('2. Updating Draft...');
        await axios.patch(http://localhost:4004/hr/MyApplications(ID=' + draftId + ',IsActiveEntity=false), 
            { firstName: 'Test', lastName: 'User', email: 'test@example.com' }, { headers });
        console.log('Draft updated.');

        console.log('3. Activating Draft...');
        let actRes = await axios.post(http://localhost:4004/hr/MyApplications(ID=' + draftId + ',IsActiveEntity=false)/HRService.draftActivate, {}, { headers });
        console.log('Draft Activated!', actRes.data);
    } catch(e) {
        console.error('ERROR:', e.response ? e.response.status + ' ' + JSON.stringify(e.response.data) : e.message);
    }
}
test();
