import json
import os
import subprocess
import time

from flask import Flask, request

app = Flask(__name__)

console_logs = None

def hardhat_cmd(npx_cmd):
    global console_logs

    console_logs = subprocess.check_output(npx_cmd, shell=True).decode('utf-8')

@app.route('/compilecontracts', methods=['GET'])
def compile_contracts():
    global console_logs

    cd_dir = 'cd ' + os.path.join(os.path.dirname(os.path.dirname(__file__)), 'js-deployer')
    hardhat_compile = 'npx hardhat compile'

    compile_cmd = ' && '.join((cd_dir, hardhat_compile))

    print('compiling contracts...')
    hardhat_cmd(compile_cmd)

    console_logs = list(filter(None, console_logs.split('\n')))
    return console_logs[-1]

@app.route('/deploymarketplace', methods=['GET'])
def deploy_marketplace():
    global console_logs

    deployment_network = request.args.get('network')
    listing_price = request.args.get('listing-price')
    contract_name = request.args.get('contract-name', default='NFTMarketDefault')

    cd_dir = 'cd ' + os.path.join(os.path.dirname(os.path.dirname(__file__)), 'js-deployer')
    hardhat_compile = 'npx hardhat compile'
    hardhat_run = 'npx hardhat run ./scripts/deploy-marketplace.js --network ' + deployment_network

    os.environ["REACT_APP_LISTING_PRICE"] = listing_price
    os.environ["REACT_APP_CONTRACT_NAME"] = contract_name
    deploy_cmd = ' && '.join((cd_dir, hardhat_compile, hardhat_run))

    print('deploying contract:', contract_name)
    hardhat_cmd(deploy_cmd)

    console_logs = list(filter(None, console_logs.split('\n')))

    nft_marketplace_address = console_logs[-1].split('=')[-1]

    return nft_marketplace_address

@app.route('/deploynft', methods=['GET'])
def deploy_nft():
    global console_logs

    deployment_network = request.args.get('network')
    contract_name = request.args.get('contract-name', default='NFTDefault')
    market_address = request.args.get('market-address')
    nft_name = request.args.get('nft-name')
    nft_symbol = request.args.get('nft-symbol')

    cd_dir = 'cd ' + os.path.join(os.path.dirname(os.path.dirname(__file__)), 'js-deployer')
    hardhat_compile = 'npx hardhat compile'
    hardhat_run = 'npx hardhat run ./scripts/deploy-nft.js --network ' + deployment_network

    os.environ["REACT_APP_CONTRACT_NAME"] = contract_name
    os.environ["REACT_APP_MARKET_ADDRESS"] = market_address
    os.environ["REACT_APP_NFT_NAME"] = nft_name
    os.environ["REACT_APP_NFT_SYMBOL"] = nft_symbol
    deploy_cmd = ' && '.join((cd_dir, hardhat_compile, hardhat_run))

    print('deploying contract:', contract_name)
    hardhat_cmd(deploy_cmd)

    console_logs = list(filter(None, console_logs.split('\n')))

    nft_address = console_logs[-1].split('=')[-1]

    return nft_address

@app.route('/getcompiledcontract', methods=['GET'])
def get_compiled_contract():

    group_name = request.args.get('group-name', default='templates')
    contract_name = request.args.get('contract-name').split('.')[0]

    contract_dir_name = contract_name + '.sol'
    compiled_contract_name = contract_name + '.json'

    compiled_contract_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)),
        'js-deployer/artifacts/contracts',
        group_name,
        contract_dir_name,
        compiled_contract_name
    )

    print(compiled_contract_path)

    if os.path.exists(compiled_contract_path):
        return json.load(
            open(
                compiled_contract_path,
                'r'
            )
        )
    else:
        return 'Compiled contract not found. Please make sure the contract was compiled (the name is case-sensitive)'