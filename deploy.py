import os
import subprocess

js_deployer_path = os.path.join(os.getcwd(), 'js-deployer')

cd_dir = 'cd ' + js_deployer_path
hardhat_compile = 'npx hardhat compile'

deploy_cmd = ' && '.join((cd_dir, hardhat_compile))

subprocess.check_call(deploy_cmd, shell=True)