const {Web3} = require("web3");
const {abi, bytecode} = require("../../out/TwentyOne.sol/TwentyOne.json");
require("dotenv").config();

async function main() {
	const web3 = new Web3(
		new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545")
	);

	const signer = web3.eth.accounts.privateKeyToAccount(
		"0x99d6a7752535defcac5a67c47d1631c9de9bb7ad6655072e309b14c749ce92b8"
	);
	web3.eth.accounts.wallet.add(signer);

	const account2 = web3.eth.accounts.privateKeyToAccount(
		"0x591dedcab507b251afe4cae36c415ba1e1c8f723782af5ea3d6dde517606362a"
	);
	web3.eth.accounts.wallet.add(account2);

	const account3 = web3.eth.accounts.privateKeyToAccount(
		"0x86cf39ebeb45d87ff84ca3f4771646c7b61ecc44b66619df2e21e6e863f65a65"
	);
	web3.eth.accounts.wallet.add(account3);

	const contract = new web3.eth.Contract(
		abi,
		"0x1171fec57e129859C809132B6d4a0dDE4d4E2b29"
	);
	contract.options.data = bytecode.object;
	contract.handleRevert = true;

	const enterContest =
		contract.methods.enterContest(
			13351666469176267036250602307518429028696461015706776848429333008092451230493n
		);
	enterContest
		.send({from: account2.address, value: 1e18})
		.on("transactionHash", function (txHash) {
			console.log(txHash);
		});
}

main().catch((err) => {
	console.log(err);
});