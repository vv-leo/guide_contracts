// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract GuideNFT is ERC721 {

    event NFTListed(address indexed recipient, uint256 indexed tokenId, uint256 price);
    event NFTDelisted(address indexed operator, uint256 indexed tokenId);
    event NFTBought(address indexed buyer, address indexed seller, uint256 indexed tokenId, uint256 price, uint256 timestamp);

    constructor() ERC721("GUID", "GUIDENFT") {}

    struct NFTInfo {
        uint256 price;
        address owner;
        bool isListed;
        bool isMinted;
    }

    mapping(uint256 => NFTInfo) public _tokenInfos;

    //上架（没有的话创建）
    function listNFT(uint256 _tokenId, uint256 _price) public returns (uint256) {
        // 确保调用者地址有效
        require(msg.sender != address(0), "Recipient address cannot be zero");

        // 错误检查：确保价格合理（非负数）
        require(_price >= 0, "Price must be non-negative");

        // 如果未铸造，执行铸造操作
        if (!_tokenInfos[_tokenId].isMinted) {
            _safeMint(msg.sender, _tokenId);
            _tokenInfos[_tokenId].isMinted = true;
            _tokenInfos[_tokenId].owner = msg.sender;
        }

        // 确保 NFT 未被上架
        require(!_tokenInfos[_tokenId].isListed, "NFT is already listed");
        require(_tokenInfos[_tokenId].isMinted, "NFT is not minted");

        // 设置 NFT 为已上架状态，并记录价格信息
        _tokenInfos[_tokenId].isListed = true;
        _tokenInfos[_tokenId].price = _price;

        // 触发事件以通知外部监听
        emit NFTListed(msg.sender, _tokenId, _price);

        // 返回 tokenId 以供后续使用
        return _tokenId;
    }

    //下架
    function deListNFT(uint256 _tokenId) public {
        require(msg.sender == _tokenInfos[_tokenId].owner, "Not the owner of this NFT");
        require(_tokenInfos[_tokenId].isMinted, "NFT is not minted");
        require(_tokenInfos[_tokenId].isListed, "NFT is not listed");

        _tokenInfos[_tokenId].isListed = false;
        _tokenInfos[_tokenId].price = 0;
        emit NFTDelisted(msg.sender, _tokenId);
    }

    // 买卖
    function buyNFT(uint256 _tokenId) public payable {

        require(_tokenInfos[_tokenId].isListed, "NFT is not listed");
        require(_tokenInfos[_tokenId].isMinted, "NFT is not minted");

        uint256 listingPrice = _tokenInfos[_tokenId].price;
        require(msg.value >= listingPrice, "Not enough funds");
        address seller = _tokenInfos[_tokenId].owner;
        require(seller != address(0), "NFT does not exist");
        require(seller != msg.sender, "Cannot buy your own NFT");

        // 转移所有权
        _safeTransfer(seller, msg.sender, _tokenId);
        _tokenInfos[_tokenId].owner = msg.sender;
        //下架操作
        deListNFT(_tokenId);

        (bool success,) = seller.call{value: msg.value}("");
        require(success, "Transfer of funds failed");

        emit NFTBought(msg.sender, seller, _tokenId, listingPrice, block.timestamp);
    }

}