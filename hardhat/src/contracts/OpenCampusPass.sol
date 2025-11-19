// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpenCampusPass is ERC721URIStorage, Ownable {
    // 学生証NFTのトークンID
    uint256 private _nextTokenId;

    // クイズの報酬額
    uint256 public rewardQuiz = 0.05 ether;

    // ユーザーがクリア済みのクイズ
    mapping(address => bool) public hasClaimed;

    // 有料ページごとの料金
    mapping(uint256 => uint256) private pageFees;

    // ページごとのアクセス権：userAddress => pageId => hasAccess
    mapping(address => mapping(uint256 => bool)) public access;

    // デプロイ時にオーナー設定
    constructor() ERC721("OC", "OC-Cert") Ownable(msg.sender) {}

    // コントラクトにETHを送金して報酬プールを作る
    receive() external payable {}

    // 学生証NFTのメタファイルのURL返却 (固定URLにしておく)
    function _baseURI() internal pure override returns (string memory) {
        return "https://example.com/metadata/fixed.json";
    }

    // 学生証NFTの発行
    function mintCert() external {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    // 学生証NFTの所持確認
    function hasNFT() external view returns (bool) {
        uint256 num = balanceOf(msg.sender);
        return num > 0;
    }

    // 学生証の発行数
    function getMintNum() external view returns (uint256) {
        return _nextTokenId;
    }

    // クイズに正解した場合の報酬付与
    function claimReward() external {
        require(!hasClaimed[msg.sender], "Already claimed");
        require(rewardQuiz > 0, "Quiz has no reward");
        require(
            address(this).balance >= rewardQuiz,
            "Not enough ETH in contract"
        );

        // 報酬支払いと記録
        hasClaimed[msg.sender] = true;
        payable(msg.sender).transfer(rewardQuiz);
    }

    // クイズ報酬を受け取ったかどうか
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
