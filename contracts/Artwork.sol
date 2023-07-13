// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Artwork {
    struct Art {
        address owner;
        string image; //path
        string description;
        uint256 price;
        string credentials;
        uint256 quantity;
    }

    struct Purchase {
        uint256 id;
        uint256 artId;
        address buyer;
        address seller;
        uint256 amount;
        bool delivery_state;
    }

    uint256 art_count;
    uint256 purchase_count;

    mapping(uint256 => Art) public artworks;
    mapping(uint256 => Purchase) public purchases;

    // Create Artwork
    function createArt(
        address _owner,
        string memory _image_path,
        string memory _description,
        uint256 _price,
        string memory _credentials,
        uint256 _quantity
    ) public {
        Art storage art = artworks[art_count];
        art.owner = _owner;
        art.image = _image_path;
        art.description = _description;
        art.price = _price;
        art.credentials = _credentials;
        art.quantity = _quantity;
        art_count++;
    }

    // Update Product Quantity
    function updateQuantity(
        uint256 art_id,
        uint256 _new_quantity
    ) public returns (uint256) {
        Art storage art = artworks[art_id];
        art.quantity = _new_quantity;
        return art.quantity;
    }

    // Complete delivery
    function startDelivery(uint256 purchase_id) public returns (bool) {
        Purchase storage purchase = purchases[purchase_id];
        purchase.delivery_state = true;
        return purchase.delivery_state;
    }

    // To be continued...
    // function getDeliveryStatus(uint256 art_id) public view returns (bool) {
    //     Art storage art = artworks[art_id];
    //     return art.delivery_state;
    // }

    // To be continued...
    function getArtQuantity(uint256 art_id) public view returns (uint256) {
        Art storage art = artworks[art_id];
        return art.quantity;
    }

    // To be continued...
    // function cancelDelivery(uint256 art_id) public returns (bool) {
    //     Art storage art = artworks[art_id];
    //     art.delivery_state = false;
    //     return art.delivery_state;
    // }

    // Get All Artworks
    function getArtworks() public view returns (Art[] memory) {
        Art[] memory allArtworks = new Art[](art_count);

        for (uint i = 0; i < art_count; i++) {
            Art storage item = artworks[i];

            allArtworks[i] = item;
        }

        return allArtworks;
    }

    // Purchase Event
    event ArtworkPurchased(
        uint256 artId,
        address buyer,
        address seller,
        uint256 amount
    );

    // Purchase Artwork and add order to purchases
    function buyArtwork(uint256 art_id) public payable {
        Art storage art = artworks[art_id];

        require(art.quantity > 0, "Artwork is out of stock");

        uint256 amount = art.price;

        require(msg.value == amount, "Incorrect payment amount");

        (bool sent, ) = payable(art.owner).call{value: amount}("");
        require(sent, "Payment failed");

        art.quantity--;

        Purchase storage purchase = purchases[purchase_count];
        purchase.id = purchase_count;
        purchase.artId = art_id;
        purchase.buyer = msg.sender;
        purchase.seller = art.owner;
        purchase.amount = amount;
        purchase.delivery_state = false;
        purchase_count++;
        emit ArtworkPurchased(art_id, msg.sender, art.owner, amount);
    }

    // Get All Purchases
    function getPurchases() public view returns (Purchase[] memory) {
        Purchase[] memory allPurchases = new Purchase[](purchase_count);
        for (uint i = 0; i < purchase_count; i++) {
            Purchase storage item = purchases[i];
            allPurchases[i] = item;
        }
        return allPurchases;
    }
}
