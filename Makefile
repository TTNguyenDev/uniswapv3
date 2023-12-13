test: 
	forge test
anvil:
	anvil --code-size-limit 50000
deployLocal:
	forge script ./script/DeployDevelopment.s.sol --broadcast --fork-url http://localhost:8545 --private-key $(PK) --code-size-limit 50000
build:
	docker build --no-cache -t foundry .
deploy:
	docker run foundry \ 
		--rpc-url $RPC_URL \
		--constructor-args "ForgeNFT" "FNFT" "https://ethereum.org" \
		--private-key $PRIVATE_KEY \
		.src/NFT.sol:NFT


