const http = require("http");
const auth = Buffer.from("testik:testik").toString("base64");

function req(method, path, body) {
    return new Promise((resolve, reject) => {
        const opts = { hostname: "127.0.0.1", port: 4007, path: "/hr" + path, method, headers: { "Content-Type": "application/json", "Authorization": "Basic " + auth } };
        const r = http.request(opts, (res) => { let d = ""; res.on("data", c => d += c); res.on("end", () => { try { resolve({s: res.statusCode, d: JSON.parse(d)}); } catch(e) { resolve({s: res.statusCode, d: d}); } }); });
        r.on("error", reject);
        if (body) r.write(JSON.stringify(body));
        r.end();
    });
}
async function main() {
    let res = await req("GET", "/Candidates");
    if (!res.d.value || res.d.value.length === 0) {
        console.log("No candidates found");
        return;
    }
    const candidateId = res.d.value[0].ID;
    console.log("Found candidate:", candidateId);
    
    console.log("Calling analyzeCV...");
    let analyze = await req("POST", `/Candidates(ID=${candidateId},IsActiveEntity=true)/HRService.analyzeCV`, {});
    console.log("Analyze Status:", analyze.s);
    console.log("Analyze Response:", analyze.d);
    
    // Check CVAnalysisResults
    let check = await req("GET", `/CVAnalysisResults`);
    console.log("CVAnalysisResults:", check.d.value);
}
main().catch(e => console.error(e));
