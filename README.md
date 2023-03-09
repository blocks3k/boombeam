#Deployment

cd into crosschainrand
run foundry install ( to install dependencies )
then set ENV variables in a .env file in project root ( MATIC and GOERLI RPC url's from INFURA)
forge script script/Counter.s.sol:CounterScript --broadcast --verify -vvvv 

This will deploy the contracts and verify on etherscan


Detailed instructions  @ https://www.youtube.com/watch?v=hNoIWLgHQrI

How it works?


Deploy File ExecutableSample : SuperRandom contract on polygon mumbai with the following args
gateway : 0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B
gasreceiver : 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6

This is deployed to 0xece175f27ac8c46d80509cb586a4f0113e67bf5c on mumbai

Now, let's play the betting game

2 ppl can bet with 0.02 MATIC by calling bet()


Switch Metamask to Moonbeam
Let's send VRF from moonbeam to polygon next

Step1 : Deploy ExecutableVRF from axelar.sol using the following params on moonbase

gateway : 0x5769D84DD62a6fD969856c75c7D321b84d455929
gasService : 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6

This is deployed to 0x6B3930fD1371CaF46FcC29BC15c240C4eeB47716

This contract should have funds to pay for VRF requets, lets send it 2 DEV

Let's call startLottery which starts VRF request, pass VALUE of 200000 Gwei

Now we can call FullFill request after waiting 2 blocks. This gives us the randomness.

Now, call setVRF with 

destinationChain : Polygon
destinationAddress : 0xece175f27ac8c46d80509cb586a4f0113e67bf5c (polgon contract)

set Value to 0.2 DEV AND SEND IT



Connect metamask to polygon now

On POlygon,

Anyone can call pickWinner(), he / she gets all funds
You can read the VRF value by calling SuperRandom.value()





