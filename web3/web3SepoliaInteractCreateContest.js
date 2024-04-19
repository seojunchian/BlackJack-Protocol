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

	const contract = new web3.eth.Contract(
		abi,
		"0x9c5da0eDdB670d3E9dbd10B0B334d7F0CF755510"
	);
	contract.options.data = bytecode.object;
	contract.handleRevert = true;

	const createContest = contract.methods.createContest("a", 2, 1e9);

	createContest
		.send({from: signer.address, value: 1e9})
		.on("transactionHash", function (txHash) {
			console.log(txHash);
		});
}

main().catch((err) => {
	console.log(err);
});
