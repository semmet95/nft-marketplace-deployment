import logging
import os
import subprocess

from flask import Flask, request

app = Flask(__name__)

@app.route('/deploymarketplace', methods=['GET'])
def deploy_marketplace():

    deployment_network = request.args.get('network')
    listing_price = request.args.get('listing-price')

    cd_dir = 'cd ' + os.path.join(os.getcwd(), 'js-deployer')
    hardhat_compile = 'npx hardhat compile'
    hardhat_run = 'npx hardhat run ./scripts/deploy.js --network ' + deployment_network

    os.environ["REACT_APP_LISTING_PRICE"] = listing_price
    deploy_cmd = ' && '.join((cd_dir, hardhat_compile, hardhat_run))

    logging.info('running hardhat command to compile and deploy contracts')
    console_logs = subprocess.check_output(deploy_cmd, shell=True).decode('utf-8')
    console_logs = list(filter(None, console_logs.split('\n')))

    nft_marketplace_address = console_logs[-1].split('=')[-1]

    return nft_marketplace_address

app.run(port=80)