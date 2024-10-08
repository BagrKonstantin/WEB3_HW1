// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ERC721Token.sol";

contract ERC721TokenTest is Test
{
    ERC721Token token;
    string tokenLink = "https://magenta-biological-penguin-759.mypinata.cloud/ipfs/QmVyeBczvvAGyDQzSQzdpQZ723QrF8oHTrtZKKLcXqX2UN";


    function setUp() public
    {
        token = new ERC721Token();
    }

    function testBuyNFT() public
    {
        token.buyNFT{value: token.pricePerNFT()}(tokenLink);

        assertEq(token.ownerOf(1), address(this));
        assertEq(token.tokenURI(1), tokenLink);
    }

    function testBuyLess() public
    {
        try token.buyNFT{value: token.pricePerNFT() - 1}(tokenLink)
        {
            assert(false);
        }
        catch
        {
            assert(true);
        }
    }

    function testBuyMore() public
    {
        try token.buyNFT{value: token.pricePerNFT() + 1}(tokenLink)
        {
            assert(false);
        }
        catch
        {
            assert(true);
        }
    }
}
