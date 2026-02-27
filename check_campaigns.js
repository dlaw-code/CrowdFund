// Campaign launch data from broadcast files
const campaigns = [
    {
        id: 1,
        file: "run-1767485425691.json",
        startAt: 1767485611,
        endAt: 1767489211,
        goal: "100 tokens",
        launchDate: new Date(1767485425691).toLocaleString()
    },
    {
        id: 2,
        file: "run-1767907226424.json",
        startAt: 1767907265,
        endAt: 1768771265,
        goal: "100 tokens",
        launchDate: new Date(1767907226424).toLocaleString()
    },
    {
        id: 3,
        file: "run-1768059312751.json",
        startAt: 1768059353,
        endAt: 1768923353,
        goal: "100 tokens",
        launchDate: new Date(1768059312751).toLocaleString()
    },
    {
        id: 4,
        file: "run-1768059672847.json",
        startAt: 1768059888,
        endAt: 1768923888,
        goal: "100 tokens",
        launchDate: new Date(1768059672847).toLocaleString()
    }
];

// Current time (January 15, 2026)
const currentTime = Math.floor(Date.now() / 1000);

console.log("=== CAMPAIGN STATUS ===\n");
console.log(`Current Unix Timestamp: ${currentTime}`);
console.log(`Current Date: ${new Date().toLocaleString()}\n`);

campaigns.forEach(campaign => {
    const isActive = currentTime >= campaign.startAt && currentTime <= campaign.endAt;
    const status = isActive ? "🟢 ACTIVE" : "🔴 EXPIRED";
    
    console.log(`Campaign #${campaign.id} (${campaign.file})`);
    console.log(`  Launched: ${campaign.launchDate}`);
    console.log(`  Start: ${new Date(campaign.startAt * 1000).toLocaleString()}`);
    console.log(`  End: ${new Date(campaign.endAt * 1000).toLocaleString()}`);
    console.log(`  Goal: ${campaign.goal}`);
    console.log(`  Status: ${status}`);
    
    if (!isActive && currentTime > campaign.endAt) {
        const daysExpired = Math.floor((currentTime - campaign.endAt) / 86400);
        console.log(`  (Expired ${daysExpired} days ago)`);
    }
    console.log();
});
