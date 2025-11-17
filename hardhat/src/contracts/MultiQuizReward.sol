// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiQuizReward is Ownable {
    // クイズIDごとの報酬額
    mapping(uint256 => uint256) public rewardPerQuiz;

    // ユーザーがクリア済みのクイズ
    mapping(address => mapping(uint256 => bool)) public hasClaimed;

    // デプロイ時にオーナー設定
    constructor() Ownable(msg.sender) {}

    // コントラクトにETHを送金して報酬プールを作る
    receive() external payable {}

    // オーナーがクイズ報酬を設定
    function setReward(uint256 quizId, uint256 amount) external onlyOwner {
        rewardPerQuiz[quizId] = amount;
    }

    // ユーザーがクイズに正解した場合に報酬を請求
    function claimReward(uint256 quizId) external {
        require(!hasClaimed[msg.sender][quizId], "Already claimed");
        uint256 reward = rewardPerQuiz[quizId];
        require(reward > 0, "Quiz has no reward");
        require(address(this).balance >= reward, "Not enough ETH in contract");

        // 報酬支払いと記録
        hasClaimed[msg.sender][quizId] = true;
        payable(msg.sender).transfer(reward);
    }

    // オーナーが残高を引き出す
    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Not enough ETH");
        payable(owner()).transfer(amount);
    }

    // 現在のコントラクト残高
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // ユーザーがすでに報酬を受け取ったか確認
    function checkClaimed(
        address user,
        uint256 quizId
    ) external view returns (bool) {
        return hasClaimed[user][quizId];
    }
}
