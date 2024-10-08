// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @title ERC721 Token with Metadata and Purchase Features
contract ERC721Token is ERC721URIStorage
{
    uint256 public tokenCounter;
    uint256 public pricePerNFT = 0.01 ether;

    constructor() ERC721("CUTENFT", "CNFT")
    {
        tokenCounter = 0;
    }

    /// @notice Enables users to mint an NFT by sending Ether
    /// @param tokenURI The URI that contains the metadata for the NFT
    function buyNFT(string memory tokenURI) external payable
    {
        require(msg.value == pricePerNFT, "Incorrect Ether value sent");
        tokenCounter += 1;
        _mint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, tokenURI);
    }

    /// @notice Allows the contract owner to withdraw collected Ether
    function withdraw() external
    {
        payable(msg.sender).transfer(address(this).balance);
    }
}
