const CONTRACT_ADDRESS = "0xB4a2099e77eB9cF87Af08b5e828FD0d555ea92b2"; // あなたのコントラクトアドレスに置き換え
const ABI = [
    "function mintCert()",
    "function hasNFT() view returns (bool)",
    "function getMintNum() view returns (uint256)",
    "function claimReward()",
    "function checkClaimed(address user) view returns (bool)",
    "function setPageFee(uint256 pageId, uint256 fee) onlyOwner",
    "function getPageFee(uint256 pageId) view returns (uint256)",
    "function payForPage(uint256) payable",
    "function checkAccess(address,uint256) view returns (bool)",
    "function withdraw(uint256 amount) onlyOwner",
    "function withdrawAll() onlyOwner",
    "function getContractBalance() view onlyOwner returns (uint256)"
];

let provider, signer, contract, userAddress;

// ウォレット接続
async function connectWallet() {
    if (!window.ethereum) {
        alert("MetaMaskが見つかりません。インストールしてください。");
        return;
    }

    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    userAddress = await signer.getAddress();

    contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
}

// 残高取得
async function getContractBalance() {
    return ethers.utils.formatEther(await contract.getContractBalance());
}

// コントラクト送金
async function sendEth(eth) {
    // ④ 送るETH量
    const value = ethers.utils.parseEther(eth);

    // ⑤ 送金（単にETH送る場合は signer.sendTransaction）
    const tx = await signer.sendTransaction({
        to: CONTRACT_ADDRESS,
        value: value,
    });

    // ⑥ 完了待ち
    const receipt = await tx.wait();
}

// コントラクト引出（指定額）
async function withdraw(eth) {
    const value = ethers.utils.parseEther(eth);
    await contract.withdraw(value);
}

// コントラクト引出（全額）
async function withdrawAll() {
    await contract.withdrawAll();
}

async function getPageFee(pageId) {
    let value = await contract.getPageFee(pageId);
    return ethers.utils.formatEther(value);
}

async function setPageFee(pageId, fee) {
    const value = ethers.utils.parseEther(fee);
    await contract.setPageFee(pageId, value);
}
