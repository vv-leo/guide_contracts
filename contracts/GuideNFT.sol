// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract GuideNFT is ERC721 {

    event NFTListed(address indexed recipient, uint256 indexed tokenId, uint256 price);
    event NFTDelisted(address indexed operator, uint256 indexed tokenId);

    constructor() ERC721("GUIDE", "GUIDENFT") {}

    struct NFTInfo {
        uint256 price;
    }

    mapping(uint256 => NFTInfo) public _tokenInfos;
    mapping(uint256 => address) public nftOwners;
    mapping(uint256 => bool) public isListed;
    mapping(uint256 => bool) public isMinted;

    //上架（没有的话创建）
    function listNFT(uint256 tokenId, uint256 price) public returns (uint256) {
        // 确保调用者地址有效
        require(msg.sender != address(0), "Recipient address cannot be zero");

        // 错误检查：确保价格合理（非负数）
        require(price >= 0, "Price must be non-negative");

        // 如果未铸造，执行铸造操作
        if (!isMinted[tokenId]) {
            _safeMint(msg.sender, tokenId);
            isMinted[tokenId] = true;
            nftOwners[tokenId] = msg.sender;
        }

        // 确保 NFT 未被上架
        require(!isListed[tokenId], "NFT is already listed");
        require(isMinted[tokenId], "NFT is not minted");

        // 设置 NFT 为已上架状态，并记录价格信息
        isListed[tokenId] = true;
        _tokenInfos[tokenId] = NFTInfo(price);

        // 触发事件以通知外部监听
        emit NFTListed(msg.sender, tokenId, price);

        // 返回 tokenId 以供后续使用
        return tokenId;
    }

    //下架
    function deListNFT(uint256 tokenId) public {
        require(msg.sender == nftOwners[tokenId], "Not the owner of this NFT");
        require(isMinted[tokenId], "NFT is not minted");
        require(isListed[tokenId], "NFT is not listed");

        isListed[tokenId] = false;
        _tokenInfos[tokenId].price = 0;
        emit NFTDelisted(msg.sender, tokenId);
    }

    // 买卖
    function buyNFT(uint256 tokenId) public payable {

        require(isListed[tokenId], "NFT is not listed");
        require(isMinted[tokenId], "NFT is not minted");

        uint256 listingPrice = _tokenInfos[tokenId].price;
        require(msg.value >= listingPrice, "Not enough funds");
        address seller = nftOwners[tokenId];
        require(seller != address(0), "NFT does not exist");
        require(seller != msg.sender, "Cannot buy your own NFT");

        // 转移所有权
        _transfer(seller, msg.sender, tokenId);
        nftOwners[tokenId] = msg.sender;
        isListed[tokenId] = false;
        _tokenInfos[tokenId].price = 0;
        (bool success,) = seller.call{value: msg.value}("");
        require(success, "Transfer of funds failed");
    }

}