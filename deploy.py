import os
import subprocess

js_deployer_path = os.path.join(os.getcwd(), 'js-deployer')
deployment_network = 'rinkeby'
listing_price = '0.025'

cd_dir = 'cd ' + js_deployer_path
hardhat_compile = 'npx hardhat compile'
hardhat_run = 'npx hardhat run ./scripts/deploy.js --network ' + deployment_network

os.environ["REACT_APP_LISTING_PRICE"] = listing_price
deploy_cmd = ' && '.join((cd_dir, hardhat_compile, 'node scripts/deploy.js'))

console_logs = subprocess.check_output(deploy_cmd, shell=True).decode('utf-8')
console_logs = list(filter(None, console_logs.split('\n')))
print(console_logs[-1])