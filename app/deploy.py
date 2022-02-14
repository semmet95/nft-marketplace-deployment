import os
import subprocess
import threading
import time

from flask import Flask, request

app = Flask(__name__)

# flag
contract_deployed = False
console_logs = None

def hardhat_cmd(deploy_cmd):
    global contract_deployed, console_logs

    console_logs = subprocess.check_output(deploy_cmd, shell=True).decode('utf-8')
    contract_deployed = True

@app.route('/deploymarketplace', methods=['GET'])
def deploy_marketplace():
    global contract_deployed, console_logs

    deployment_network = request.args.get('network')
    listing_price = request.args.get('listing-price')

    cd_dir = 'cd ' + os.path.join(os.path.dirname(os.path.dirname(__file__)), 'js-deployer')
    hardhat_compile = 'npx hardhat compile'
    hardhat_run = 'npx hardhat run ./scripts/deploy.js --network ' + deployment_network

    os.environ["REACT_APP_LISTING_PRICE"] = listing_price
    deploy_cmd = ' && '.join((cd_dir, hardhat_compile, hardhat_run))

    print('starting contract deployment')
    threading.Thread(target=hardhat_cmd(deploy_cmd)).start()

    while not contract_deployed:
        print('waiting for the contract to be deployed...')
        time.sleep(5)

    console_logs = list(filter(None, console_logs.split('\n')))

    nft_marketplace_address = console_logs[-1].split('=')[-1]

    return nft_marketplace_address