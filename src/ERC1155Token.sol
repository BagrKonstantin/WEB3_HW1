// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/// @title ERC1155 Token with Metadata and Purchase Features
contract ERC1155Token is ERC1155
{
    uint256 public pricePerToken = 0.01 ether;
    
    constructor() ERC1155("https://magenta-biological-penguin-759.mypinata.cloud/ipfs/QmWM7JhaQ7kwXpaUVGb42vWZzp2bFWAYzaoKSA76Tkmukc") {}

    /// @notice Enables users to purchase a specific token by sending Ether
    /// @param id The ID of the token being purchased
    /// @param amount The quantity of tokens to purchase
    function buyToken(address to, uint256 id, uint256 amount) external payable
    {
        require(msg.value == pricePerToken * amount, "Incorrect Ether value");
        _mint(to, id, amount, "");
    }

    /// @notice Allows the contract owner to withdraw collected Ether
    function withdraw() external
    {
        payable(msg.sender).transfer(address(this).balance);
    }
}
