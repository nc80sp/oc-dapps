const CONTRACT_ADDRESS = "0xB00a017D38E6a4669761dA1EB9F1099450b6aa2c"; // あなたのコントラクトアドレスに置き換え
const ABI = [
    "event Minted(address indexed to, uint256 indexed tokenId, string tokenURI)",
    "function setMetadataURI(uint256,string memory uri) onlyOwner",
    "function getMetadataURI(uint256 typeId) view returns(string memory)",
    "function mintNFT(uint256)",
    "function hasNFT(uint256) view returns (uint256)",
    "function getMintNum(uint256) view returns (uint256)",
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

const NFT_TYPE = Object.freeze({
    PARTICIPATION: 1,
    COMPLETE: 2,
});

let provider, signer, contract, userAddress, isClaimed = false;

function GetContractAddress() {
    return CONTRACT_ADDRESS;
}

// ウォレット接続
async function connectWallet(checkNFT) {
    if (!window.ethereum) {
        alert("MetaMaskが見つかりません。インストールしてください。");
        return false;
    }

    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    userAddress = await signer.getAddress();

    contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

    if (checkNFT) {
        if (await contract.hasNFT(NFT_TYPE.PARTICIPATION) == false) {
            alert("参加証NFTを所持していないため、アクセスできません。");
            return false;
        }
    }
    return true;
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
    await provider.waitForTransaction(tx.hash);
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

// ページ料金の取得
async function getPageFee(pageId) {
    let value = await contract.getPageFee(pageId);
    return ethers.utils.formatEther(value);
}

// ページ料金の設定
async function setPageFee(pageId, fee) {
    const value = ethers.utils.parseEther(fee);
    await contract.setPageFee(pageId, value);
}

// NFTメタデータの設定
async function setMetadataURI(typeId, uri) {
    await contract.setMetadataURI(typeId, uri);
}

// NFTメタデータの取得
async function getMetadataURI(typeId) {
    await contract.getMetadataURI(typeId);
}

// NFTの発行
async function mintNFT(typeId) {
    const tx = await contract.mintNFT(typeId,
        { gasLimit: 1000000 }
    );

    const receipt = await provider.waitForTransaction(tx.hash);

    if (receipt && receipt.status === 1) {
        // receipt.logs から解析
        const event = receipt.logs
            .map(log => {
                try {
                    return contract.interface.parseLog(log);
                } catch {
                    return null;
                }
            })
            .find(e => e && e.name === "Minted");

        if (event) {
            const tokenId = event.args.tokenId.toString();
            const tokenURI = event.args.tokenURI;
            return tokenId;

            /*
            const res = await fetch(tokenURI);
            console.log(res);
            const metadata = await res.json();
            console.log(metadata);
            const imageUrl = metadata.image;
            console.log(imageUrl);
            //NFT追加の確認ダイアログ表示（Mainnetしか自動追加されないので)
            await window.ethereum.request({
                method: "wallet_watchAsset",
                params: {
                    type: "ERC721",
                    options: {
                        address: CONTRACT_ADDRESS,
                        tokenId: tokenId.toString(),
                        image: imageUrl
                    },
                },
            });
            */
        }
    }
    return 0;
}

// NFTの所持確認
async function hasNFT(typeId) {
    return await contract.hasNFT(typeId);
}

// NFT発行数の確認
async function getMintNum(typeId) {
    return await contract.getMintNum(typeId);
}

// 報酬付与確認
async function checkClaimed() {
    isClaimed = await contract.checkClaimed(userAddress);
    return isClaimed;
}

// 報酬付与
async function claimedReward() {
    if (!isClaimed) {
        const tx = await contract.claimReward(
            { gasLimit: 1000000 });
        const receipt = await provider.waitForTransaction(tx.hash);
        if (receipt) {
            // 報酬付与完了
            isClaimed = true;
            return true;
        } else {
            return false;
        }
    } else {
        // 報酬付与は付与済み
        return false;
    }
}
