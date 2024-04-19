const {Web3} = require("web3");
const {abi, bytecode} = require("../out/Contest.sol/Contest.json");
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
		"0x2085a4c1379Ba8770b7ab6eC2Ad86dC268B1A2dA"
	);
	contract.options.data = bytecode.object;
	contract.handleRevert = true;
	/*
	const createContest = contract.methods.createContest(
		"a",
		3,
		web3.utils.toWei("1", "ether")
	);
	createContest
		.send({from: signer.address, value: 1e9})
		.on("transactionHash", (txHash) => {
			console.log(txHash);
		});*/
	console.log(await contract);
}

main().catch((err) => {
	console.log(err);
});
