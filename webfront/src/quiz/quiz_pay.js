
let isClaimed = false;
async function checkClaimed() {
    isClaimed = await contract.checkClaimed(userAddress);
}

async function claimedReward() {
    if (!isClaimed) {
        const tx = await contract.claimReward();
        await tx.wait();
        // 報酬付与完了
        isClaimed = true;
        return true;
    } else {
        // 報酬付与は付与済み
        return false;
    }
}
