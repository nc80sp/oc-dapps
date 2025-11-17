// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//OC学生証の発行
contract MyNFT is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    constructor() ERC721("OC", "OC-Cert") Ownable(msg.sender) {}
    function _baseURI() internal pure override returns (string memory) {
        // NFTメタファイルのURL
        return "https://example.com/metadata/fixed.json";
    }

    // 学生証の発行
    function mintCert() external {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    // トークンの所持確認
    function hasNFT(address user) external view returns (bool) {
        uint256 num = balanceOf(user);
        return num > 0;
    }

    // 学生証の発行数
    function getMintNum() external view returns (uint256) {
        return _nextTokenId;
    }
}
