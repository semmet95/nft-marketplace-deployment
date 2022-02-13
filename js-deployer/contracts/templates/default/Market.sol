// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "../../modules/libs/Counters.sol";

import "../../modules/ReentrancyGuard.sol";
import "../../modules/IERC721.sol";

contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner;
  uint256 listingPrice;

  constructor(uint256 listPrice) {
    owner = payable(msg.sender);
    listingPrice = listPrice * (1 ether);
  }

  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    uint256 creator_royalty;// in percentage
    bool sold;
  }

  mapping(uint256 => MarketItem) private idToMarketItem;

  event MarketItemCreated (
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    uint256 creator_royalty,
    bool sold
  );

  /* Returns the listing price of the contract */
  function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }
  
  /* Places an item for sale on the marketplace */
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    uint256 price,
    uint256 royalty
  ) public payable nonReentrant {
    require(price > 0, "Price must be at least 1 wei");
    require(royalty < 20, "royalty cant not be more than  20% ");
    require(msg.value == listingPrice, "Price must be equal to listing price");
    require(IERC721(address(nftContract)).creatorOf(tokenId)==IERC721(address(nftContract)).ownerOf(tokenId), "You must be creator of this nft to call this");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();
  
    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price,
      royalty,
      false
    );

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      price,
      royalty,
      false
    );
  }

  /* Places an item for resell on the marketplace */
  function resellMarketItem(
    uint256 itemId,
    uint256 price
  ) public payable nonReentrant {
    require(price > 10, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "Price must be equal to listing price");
    require(msg.sender==IERC721(address(idToMarketItem[itemId].nftContract)).ownerOf(idToMarketItem[itemId].tokenId), "You must be creator of this nft to call this");

    MarketItem storage market_item = idToMarketItem[itemId];

    market_item.seller = payable(msg.sender);
    market_item.sold = false;
    market_item.owner = payable(address(0));
    market_item.price = price;
    _itemsSold.decrement();
    IERC721(market_item.nftContract).transferFrom(msg.sender, address(this), market_item.tokenId);
  }

  /* Creates the sale of a marketplace item */
  /* Transfers ownership of the item, as well as funds between parties */
  function createMarketSale(
    address nftContract,
    uint256 itemId
  ) public payable nonReentrant {

    uint price = idToMarketItem[itemId].price;
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    //give royalties to original creator
    uint256 creatorCut = 0;
    if (IERC721(address(nftContract)).creatorOf(tokenId)!=IERC721(address(nftContract)).ownerOf(tokenId)){
        creatorCut = (msg.value * idToMarketItem[itemId].creator_royalty) / 100;
    
        if (creatorCut > 0) {
                payable(IERC721(address(nftContract)).creatorOf(tokenId)).transfer(creatorCut);
        }
    }
    idToMarketItem[itemId].seller.transfer(msg.value-creatorCut);
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
    idToMarketItem[itemId].owner = payable(msg.sender);
    idToMarketItem[itemId].sold = true;
    _itemsSold.increment();
    payable(owner).transfer(listingPrice);
  }

  /* Returns all unsold market items */
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0)) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }



  /* Returns items that a user has purchased */
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns only items a user has created */
  function fetchItemsCreated() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
  
    
  function nftItemInfo(uint item_id) public view returns(
    uint itemId,
    address nftContract,
    uint256 tokenId,
    address item_seller,
    address item_owner,
    uint256 price,
    uint256 creator_royalty,
    bool sold
    ) {
        require( item_id >= _itemIds.current(), "no NFT exists");
        MarketItem storage Item = idToMarketItem[item_id];
        return(Item.itemId, Item.nftContract,Item.tokenId,Item.seller,Item.owner,Item.price,Item.creator_royalty,Item.sold);
    }  
  
}
