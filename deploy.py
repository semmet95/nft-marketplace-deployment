import os
import subprocess

js_deployer_path = os.path.join(os.getcwd(), 'js_deployer')
compile_cmd = 'cd ' + js_deployer_path + ' && npx hardhat compile'

subprocess.check_call(compile_cmd, shell=True)