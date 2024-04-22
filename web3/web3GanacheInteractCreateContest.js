const {Web3} = require("web3");
const {abi, bytecode} = require("../out/TwentyOne.sol/TwentyOne.json");
require("dotenv").config();

async function main() {
	const web3 = new Web3(
		new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545")
	);

	const signer = web3.eth.accounts.privateKeyToAccount(
		"0x99d6a7752535defcac5a67c47d1631c9de9bb7ad6655072e309b14c749ce92b8"
	);
	web3.eth.accounts.wallet.add(signer);

	const contract = new web3.eth.Contract(
		abi,
		"0x161d68aD47DeE62bb16E9f372F2285e5F753c1d7"
	);
	contract.options.data = bytecode.object;
	contract.handleRevert = true;

	const createContest = contract.methods.createContest(
		"a",
		web3.utils.toWei("1", "ether")
	);
	createContest
		.send({from: signer.address, value: 1e13})
		.on("transactionHash", (txHash) => {
			console.log(txHash);
		});
}

main().catch((err) => {
	console.log(err);
});
