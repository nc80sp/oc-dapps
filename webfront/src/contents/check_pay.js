const CONTRACT_ADDRESS = "0xd5Ba89f8a5a07Bf1409DCaAF2E1827840B96e173"; // あなたのコントラクトアドレスに置き換え
const ABI = [
    "function payForPage(uint256) payable",
    "function checkAccess(address,uint256) view returns (bool)",
    "function withdraw() onlyOwner"
];

let provider, signer, contract, userAddress, pageId;

async function connectWallet() {
    if (!window.ethereum) {
        alert("MetaMaskが見つかりません。インストールしてください。");
        return;
    }

    const path = window.location.pathname;
    const segments = path.split("/").filter(Boolean);
    let currentDir = segments.length > 0 ? segments[segments.length - 1] : "";
    console.log("現在のディレクトリ名:", currentDir);
    pageId = currentDir;

    // ✅ ethers.providers.Web3Provider は v5 用
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    userAddress = await signer.getAddress();

    contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
    checkAccess();
}

async function checkAccess() {
    var hasAccess = await contract.checkAccess(userAddress, pageId);
    hasAccess = true;
    if (!hasAccess) {
        document.getElementById("loading").innerHTML = "サイト閲覧の権限がありません";
        redirectToFolder();
    } else {
        // 読み込み中メッセージを非表示
        document.getElementById("loading").style.display = "none";

        // コンテンツを表示
        document.getElementById("content").style.display = "block";
    }
}

function redirectToFolder() {
    const base = window.location.origin;
    const target = `${base}/contents/?id=` + pageId;
    setTimeout(() => (window.location.href = target), 1500);
}

document.addEventListener("DOMContentLoaded", async () => {
    connectWallet();
});
