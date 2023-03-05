import styles from "../styles/InstructionsComponent.module.css";
import * as React from 'react';
import { useAccount, useContractWrite, useEnsName } from 'wagmi'
import abi from "./abi.json";
import betAbi from "./betAbi.json";
import fullFillAbi from "./fullFillAbi.json";
import { ethers } from "ethers";
function useDebounce(value, delay) {
	// State and setters for debounced value
	const [debouncedValue, setDebouncedValue] = React.useState(value);
	React.useEffect(
		() => {
			// Update debounced value after delay
			const handler = setTimeout(() => {
				setDebouncedValue(value);
			}, delay);
			// Cancel the timeout if value changes (also on delay change or unmount)
			// This is how we prevent debounced value from updating if value is changed ...
			// .. within the delay period. Timeout gets cleared and restarted.
			return () => {
				clearTimeout(handler);
			};
		},
		[value, delay] // Only re-call effect if value or delay changes
	);
	return debouncedValue;
}
export default function AxelarComponent() {
	const { address, isConnected } = useAccount()
	const [isLoading, setIsLoading] = React.useState(false)
	const [data, setData] = React.useState();
	const [isSuccess, setIsSuccess] = React.useState(false)

	const doWrite = async (e) => {
		e.preventDefault();
		setIsLoading(true);
		const provider = new ethers.providers.Web3Provider(window.ethereum)
		const signer = provider.getSigner()
		const contract = new ethers.Contract("0x897659a6a6aedc45d8a384b724b34ba365f4103d", abi, signer);
		const transaction = await contract.setRemoteValue("Polygon", "0x955f05543c9ff76843df04f944e5a1e4952bfc5d", { value: ethers.utils.parseEther("0.005") })
		const data = await transaction.wait();
		console.log(data)
		setIsLoading(false);
		setIsSuccess(true);
		setData(data);
	}

	const getCurrentRandomness = async (e) => {
		e.preventDefault();
		const provider = new ethers.providers.Web3Provider(window.ethereum)
		const signer = provider.getSigner()
		const contract = new ethers.Contract("0x955f05543c9ff76843df04f944e5a1e4952bfc5d", abi, signer);
		const data = await contract.value();
		alert(`Randomness Value = ${data}`)
	}

	const betThis = async (e) => {		e.preventDefault();

		const provider = new ethers.providers.Web3Provider(window.ethereum)
		const signer = provider.getSigner()
		const contract = new ethers.Contract("0xece175f27ac8c46d80509cb586a4f0113e67bf5c", betAbi, signer);
		const transaction = await contract.bet({ value: ethers.utils.parseEther("0.02") })
		const data = await transaction.wait();
		alert("bet complete");
	}

	const startMoonbeamProcess = async (e) => {
		e.preventDefault();
		await window.ethereum.request({
			method: "wallet_addEthereumChain",
			params: [{
				chainId: "0x507",
				rpcUrls: ["https://rpc.api.moonbase.moonbeam.network"],
				chainName: "Moonbase Alpha",
				nativeCurrency: {
					name: "DEV",
					symbol: "DEV",
					decimals: 18
				},
				blockExplorerUrls: ["https://moonbase.moonscan.io"]
			}]
		});
		const provider = new ethers.providers.Web3Provider(window.ethereum)
		const signer = provider.getSigner()
		const contract = new ethers.Contract("0x6B3930fD1371CaF46FcC29BC15c240C4eeB47716", fullFillAbi, signer);
		const transaction = await contract.startLottery({ value: ethers.utils.parseEther("0.0002") })
		const data = await transaction.wait();
		alert("lottery started");
	}

	const fullfillRequest = async (e) => {
		e.preventDefault();

		const provider = new ethers.providers.Web3Provider(window.ethereum)
		const signer = provider.getSigner()
		const contract = new ethers.Contract("0x6B3930fD1371CaF46FcC29BC15c240C4eeB47716", fullFillAbi, signer);
		let transaction = await contract.fulfillRequest()
		let data = await transaction.wait();
		alert("full request done.");

		transaction = await contract.setVRF("Polygon","0xece175f27ac8c46d80509cb586a4f0113e67bf5c",
			{ value: ethers.utils.parseEther("0.2") });
		data = await transaction.wait();
		alert("set vrf done");
	}

	const pickWinner = async (e) => {
		e.preventDefault();
		await window.ethereum.request({
			method: "wallet_addEthereumChain",
			params: [{
				chainId: "0x13881",
				rpcUrls: ["https://polygon-mumbai.blockpi.network/v1/rpc/public"],
				chainName: "Polygon Mumbai",
				nativeCurrency: {
					name: "MATIC",
					symbol: "MATIC",
					decimals: 18
				},
				blockExplorerUrls: ["https://polygonscan.com/"]
			}]
		});
		const provider = new ethers.providers.Web3Provider(window.ethereum)
		const signer = provider.getSigner()
		const contract = new ethers.Contract("0xece175f27ac8c46d80509cb586a4f0113e67bf5c", betAbi, signer);
		let transaction = await contract.pickWinner()
		let data = await transaction.wait();
		// console.log("winner", data);
		alert(`winner picked ${data["events"][0]["topics"][3]}`);

		transaction = await contract.value();
		alert(`Randomness was ${transaction}`);
	}

	return (
		<div className={styles.container}>
			<header className={styles.header_container}>
				<h1>
					Cross Chain <span>Randomness</span>
				</h1>
				<p>
					Get randomness from Ethereum RANDAO on other chains using Axelar and use it for anything!
				</p>
			</header>

			<br/>
			<h1>
				RANDAO Exported
			</h1>


			<div className={styles.buttons_container}>
				<a
					onClick={(e) => {
						doWrite(e);
					}}>

					<div className={styles.button}>
						<p>Request Randomness On Polygon</p>
					</div>
				</a>

				<a
					onClick={(e) => {
						getCurrentRandomness(e);
					}}>

					<div className={styles.button}>
						<p>Get Current Value from Polygon</p>
					</div>
				</a>
			</div>

			<br/>
			<br/>
			<h1>
				VRF Exported
			</h1>

			<div className={styles.buttons_container}>
				<a
					onClick={(e) => {
						betThis(e);
					}}>

					<div className={styles.button}>
						<p>Bet on Polygon</p>
					</div>
				</a>

				<a
					onClick={(e) => {
						startMoonbeamProcess(e);
					}}>

					<div className={styles.button}>
						<p>Start Lottery</p>
					</div>
				</a>

				<a
					onClick={(e) => {
						fullfillRequest(e);
					}}>

					<div className={styles.button}>
						<p>FullFill Request & Set VRF</p>
					</div>
				</a>

				<a
					onClick={(e) => {
						pickWinner(e);
					}}>

					<div className={styles.button}>
						<p>Pick Winner</p>
					</div>
				</a>

				{isLoading && <p><br/>Submitted and waiting for transaction....</p>}
				{isSuccess && <p><br/>Done! (<a target={"_blank"} href={`https://goerli.etherscan.io/tx/${data?.transactionHash}`}>Click for Etherscan link</a>)</p>}
				{isSuccess && <p><br/>Axelar Testnet Explorer (<a target={"_blank"} href={`https://testnet.axelarscan.io/gmp/${data?.transactionHash}`}>Link</a>)</p>}
			</div>
			<div>
				<p>Made with 💙</p>
			</div>
		</div>
	);
}
