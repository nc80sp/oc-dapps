// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpenCampusPass is ERC721URIStorage, Ownable {
    // NFTのトークンID
    uint256 private _nextTokenId = 1;

    // tokenId → NFTタイプ（1,2,3など）
    mapping(uint256 => uint256) public tokenType;

    // NFTタイプ → メタデータURL
    mapping(uint256 => string) public metadataURI;

    // 報酬額
    uint256 public reward = 0.05 ether;

    // ユーザーがクリア済みのクイズ
    mapping(address => bool) public hasClaimed;

    // 有料ページごとの料金
    mapping(uint256 => uint256) private pageFees;

    // ページごとのアクセス権：userAddress => pageId => hasAccess
    mapping(address => mapping(uint256 => bool)) public access;

    // mintイベント
    event Minted(address indexed to, uint256 indexed tokenId, string tokenURI);

    // デプロイ時にオーナー設定
    constructor() ERC721("OC", "OC-Cert") Ownable(msg.sender) {}

    // コントラクトにETHを送金して報酬プールを作る
    receive() external payable {}

    // 管理者が NFT タイプごとのメタデータURLを設定
    function setMetadataURI(
        uint256 typeId,
        string memory uri
    ) external onlyOwner {
        metadataURI[typeId] = uri;
    }

    // メタデータURLを取得
    function getMetadataURI(
        uint256 typeId
    ) external view returns (string memory) {
        return metadataURI[typeId];
    }

    // NFTの発行
    function mintNFT(uint256 typeId) external {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _safeMint(msg.sender, tokenId);

        // NFT種類を記録
        tokenType[tokenId] = typeId;
        // URI設定
        _setTokenURI(tokenId, metadataURI[typeId]);

        // イベントで tokenId, URI を返す
        emit Minted(msg.sender, tokenId, metadataURI[typeId]);
    }

    // 特定のNFTタイプを持っているか確認
    function hasNFT(uint256 typeId) external view returns (bool) {
        for (uint256 i = 1; i < _nextTokenId; i++) {
            if (ownerOf(i) == msg.sender && tokenType[i] == typeId) {
                return true;
            }
        }
        return false;
    }

    // NFTの発行数
    function getMintNum(uint256 typeId) external view returns (uint256) {
        uint256 num = 0;
        for (uint256 i = 1; i < _nextTokenId; i++) {
            if (tokenType[i] == typeId) {
                num++;
            }
        }
        return num;
    }

    // 報酬付与
    function claimReward() external {
        require(!hasClaimed[msg.sender], "Already claimed");
        require(reward > 0, "Quiz has no reward");
        require(address(this).balance >= reward, "Not enough ETH in contract");

        // 報酬支払いと記録
        hasClaimed[msg.sender] = true;
        payable(msg.sender).transfer(reward);
    }

    // 報酬を受け取ったかどうか
    function checkClaimed(address user) external view returns (bool) {
        return hasClaimed[user];
    }

    // 有料ページの料金設定（オーナーのみ）
    function setPageFee(uint256 pageId, uint256 fee) external onlyOwner {
        pageFees[pageId] = fee;
    }

    // 有料ページの料金取得
    function getPageFee(uint256 pageId) external view returns (uint256) {
        return pageFees[pageId];
    }

    // 有料ページのアクセス権をETH支払いで購入
    // payable指定でコントラクトがユーザーからETHを受け取る
    function payForPage(uint256 pageId) external payable {
        require(msg.value >= pageFees[pageId], "Not enough ETH sent");
        access[msg.sender][pageId] = true;
    }

    // 有料ページのアクセス確認
    function checkAccess(
        address user,
        uint256 pageId
    ) external view returns (bool) {
        return access[user][pageId];
    }

    // オーナーが指定の残高を引き出す
    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Not enough ETH");
        payable(owner()).transfer(amount);
    }

    // オーナーが全残高を引き出す
    function withdrawAll() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // 現在のコントラクト残高
    function getContractBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
