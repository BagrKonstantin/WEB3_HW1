// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/ERC20Token.sol";
import "../src/ERC721Token.sol";
import "../src/ERC1155Token.sol";

contract Amoy is Script {
    ERC20Token erc20Token;
    ERC721Token erc721Token;
    ERC1155Token erc1155Token;

    // Адреса контрактов
    address erc20Address = 0x3F0Ff92dd2F6B2b7f1b96ac260259D9762DF8fB4;
    address erc721Address = 0x01bDda65C80f1E5A53E8f6C498784d30F5267325;
    address erc1155Address = 0xd2BFBB228972aa9216D18357f88C73ec625a2a80;
    address senderAddress = 0x202ebff6AE673b0f44eA5DbDE5639d2D8A9935A2;
    address recipientAddress = 0xeB879DfA6DA894E30857fdeDb02f9a6D298960e4;

    function setUp() public
    {
        erc20Token = ERC20Token(erc20Address);
        erc721Token = ERC721Token(erc721Address);
        erc1155Token = ERC1155Token(erc1155Address);
    }

    function run() public
    {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        console.log("ERC20");
        testMintERC20();
        console.log("ERC721");
        testSafeMintERC721();
        console.log("ERC1155");
        testBuyERC1155();

        console.log("Balance:");
        checkAllBalances();

        console.log("Events:");
        testQueryAllAndFilterEvents();

        vm.stopBroadcast();
    }


    function testMintERC20() internal {
        uint256 initialBalance = erc20Token.balanceOf(senderAddress);
        console.log("Initial balance:", initialBalance);
        erc20Token.buyToken{value: 0.02 ether}();

        console.log("Balance after mint:", erc20Token.balanceOf(senderAddress));

        erc20Token.transfer(recipientAddress, 5 ether);
        console.log("Transferred 5 tokens");

        erc20Token.approve(senderAddress, 5 ether);
        erc20Token.transferFrom(senderAddress, recipientAddress, 2 ether);
        console.log("Transferred 5 tokens using transferFrom");
    }

    function testSafeMintERC721() internal {
        erc721Token.buyNFT{value: 0.01 ether}("https://magenta-biological-penguin-759.mypinata.cloud/ipfs/QmVyeBczvvAGyDQzSQzdpQZ723QrF8oHTrtZKKLcXqX2UN");
        console.log("Minted new NFT");
    }


    function testBuyERC1155() internal {
        erc1155Token.buyToken{value: 0.01 ether}(senderAddress, 1, 1);
        console.log("Bought 1 token");

        erc1155Token.safeTransferFrom(senderAddress, recipientAddress, 1, 1, "");
        console.log("Safe transferred 1 token");
    }

    function getERC20BalanceSlot(address user) internal view returns (uint256) {
        bytes32 slot = keccak256(abi.encode(user, 0));
        bytes32 balanceSlot;
        assembly {
            balanceSlot := sload(slot)
        }
        return uint256(balanceSlot);
    }

    function getERC1155BalanceSlot(address user, uint256 tokenId) internal view returns (uint256) {
        bytes32 slot = keccak256(abi.encode(user, keccak256(abi.encode(tokenId, 1))));
        bytes32 balanceSlot;
        assembly {
            balanceSlot := sload(slot)
        }
        return uint256(balanceSlot);
    }

    function checkAllBalances() public view {
        console.log("ERC20:", getERC20BalanceSlot(senderAddress));
        console.log("ERC721:", erc721Token.balanceOf(senderAddress));
        console.log("ERC1155:", getERC1155BalanceSlot(senderAddress, 1));
    }


    function emitLogTransfer(Vm.Log memory log) internal {
        console.log("Event Transfer detected at:");
        console.log(" - Address:", log.emitter);
        address from = address(uint160(uint256(log.topics[1])));
        address to = address(uint160(uint256(log.topics[2])));
        console.log(" - From:", from);
        console.log(" - To:", to);

        uint256 value = abi.decode(log.data, (uint256));
        console.log(" - Value:", value);
    }

    function emitLogTransferSingle(Vm.Log memory log) internal {
        address operator = address(uint160(uint256(log.topics[1])));
        address from = address(uint160(uint256(log.topics[2])));
        address to = address(uint160(uint256(log.topics[3])));
        (uint256 id, uint256 value) = abi.decode(log.data, (uint256, uint256));

        console.log("TransferSingle Event: Operator", operator);
        console.log("From", from, "To", to);
        console.log("ID", id, "Value", value);
    }

    function emitLogTransferBatch(Vm.Log memory log) internal {
        address operator = address(uint160(uint256(log.topics[1])));
        address from = address(uint160(uint256(log.topics[2])));
        address to = address(uint160(uint256(log.topics[3])));
        (uint256[] memory ids, uint256[] memory values) = abi.decode(log.data, (uint256[], uint256[]));

        console.log("TransferBatch Event: Operator", operator);
        console.log("From", from, "To", to);
        for (uint256 i = 0; i < ids.length; i++) {
            console.log(" - ID:", ids[i], "Value:", values[i]);
        }
    }

    function filterOfLogs(Vm.Log[] memory logs) internal {
        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == keccak256("Transfer(address,address,uint256)")) {
                emitLogTransfer(logs[i]);
            } else if (logs[i].topics[0] == keccak256("TransferSingle(address,address,address,uint256,uint256)")) {
                emitLogTransferSingle(logs[i]);
            } else if (logs[i].topics[0] == keccak256("TransferBatch(address,address,address,uint256[],uint256[])")) {
                emitLogTransferBatch(logs[i]);
            }
        }
    }

    function testQueryAllAndFilterEvents() internal {
        vm.recordLogs();
        erc1155Token.buyToken{value: 0.02 ether}(senderAddress, 1, 2);
        erc20Token.transfer(senderAddress, 1 * 10 ** 18);
        erc1155Token.safeTransferFrom(senderAddress, recipientAddress, 1, 1, "");

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;
        uint256[] memory amount = new uint256[](1);
        amount[0] = 1;

        erc1155Token.safeBatchTransferFrom(senderAddress, recipientAddress, ids, amount, "");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        filterOfLogs(logs);
    }
}
