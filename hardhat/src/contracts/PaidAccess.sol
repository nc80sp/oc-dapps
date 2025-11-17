// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";

// 複数ページの支払い確認
contract PaidAccess is Ownable {
    uint256 public price = 0.001 ether;

    // デプロイ時にオーナー設定
    constructor() Ownable(msg.sender) {}

    // ページごとのアクセス権：userAddress => pageId => hasAccess
    mapping(address => mapping(uint256 => bool)) public access;

    // ETH支払いで特定ページのアクセス権を付与
    // payable指定でETH受け取りを示し、トランザクション成功時に残高の更新が行われる
    // external指定で外部からのみ呼び出し可
    function payForPage(uint256 pageId) external payable {
        require(msg.value >= price, "Not enough ETH sent");
        access[msg.sender][pageId] = true;
    }

    // アクセス確認
    function checkAccess(
        address user,
        uint256 pageId
    ) external view returns (bool) {
        return access[user][pageId];
    }

    // オーナーがETHを引き出す
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
