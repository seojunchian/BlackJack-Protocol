const {Web3} = require("web3");
const {abi, bytecode} = require("../out/Contest.sol/Contest.json");
require("dotenv").config();

async function main() {
	const web3 = new Web3(
		new Web3.providers.HttpProvider(process.env.SEPOLIA_API)
	);

	const signer = web3.eth.accounts.privateKeyToAccount(
		process.env.SENDER_PRIVATE_KEY
	);
	web3.eth.accounts.wallet.add(signer);

	const ACCOUNT2 = web3.eth.accounts.privateKeyToAccount(
		process.env.ACCOUNT2_PRIVATE_KEY
	);
	web3.eth.accounts.wallet.add(ACCOUNT2);

	const ACCOUNT3 = web3.eth.accounts.privateKeyToAccount(
		process.env.ACCOUNT3_PRIVATE_KEY
	);
	web3.eth.accounts.wallet.add(ACCOUNT3);

	const contract = new web3.eth.Contract(
		abi,
		"0x9c5da0eDdB670d3E9dbd10B0B334d7F0CF755510"
	);
	contract.options.data = bytecode.object;
	contract.handleRevert = true;

	const purchaseTicket = contract.methods.purchaseTicket("a", "a", 1);

	purchaseTicket
		.send({from: ACCOUNT3.address, value: 1e9})
		.on("transactionHash", function (txHash) {
			console.log(txHash);
		});
}

main().catch((err) => {
	console.log(err);
});
