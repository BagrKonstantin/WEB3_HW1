if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

forge create --rpc-url $MUMBAI_RPC_URL \
  --private-key $PRIVATE_KEY \
  src/ERC20Token.sol:ERC20TokenWithFeeAndPermit \
  --etherscan-api-key $ETHERSCAN_API_KEY --verify

forge create --rpc-url $MUMBAI_RPC_URL \
  --private-key $PRIVATE_KEY \
  src/ERC721Token.sol:ERC721Token \
  --etherscan-api-key $ETHERSCAN_API_KEY --verify

forge create --rpc-url $MUMBAI_RPC_URL \
  --private-key $PRIVATE_KEY \
  src/ERC1155Token.sol:ERC1155Token \
  --etherscan-api-key $ETHERSCAN_API_KEY --verify